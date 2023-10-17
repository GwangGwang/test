package main

import (
	"context"
	"flag"
	"os"
	"strings"

	"dagger.io/dagger"
)


func RunSh(ctx context.Context, container *dagger.Container, script string) (string, error) {
	script = strings.ReplaceAll(script, "\n", "\\\n")
	value, err := container.WithExec([]string{"sh", "-c", script}).Stdout(ctx)
	return strings.TrimSpace(value), err
}

func getTagVersion(ctx context.Context, container *dagger.Container) (string, error) {
	return RunSh(ctx, container, "git describe --tags | sed 's/^v//'")
}

func getCommitHash(ctx context.Context, container *dagger.Container) (string, error) {
	return RunSh(ctx, container, "git rev-parse HEAD")
}

func WithGoInstallDependecies() dagger.WithContainerFunc {
	return func(r *dagger.Container) *dagger.Container {
		return r.
			WithExec([]string{
				"go", "mod", "tidy",
			}).
			WithExec([]string{
				"go", "generate", "modules/modules.go",
			})
	}
}

func WithGoVet() dagger.WithContainerFunc {
	return func(r *dagger.Container) *dagger.Container {
		return r.WithExec([]string{
			"go", "vet", "-composites=false", "./...",
		})
	}
}

func WithGoTest() dagger.WithContainerFunc {
	return func(r *dagger.Container) *dagger.Container {
		return r.
			WithExec([]string{
				"go", "test", "-race", "-run", "^TestRace.*$", "-count=1", "./...",
			}).
			WithExec([]string{
				"go", "test", "-timeout", "120s", "./...",
			})
	}
}

func WithBuildBinary() dagger.WithContainerFunc {
	return func(r *dagger.Container) *dagger.Container {
		ctx := context.Background()

		tagVersion, err := getTagVersion(ctx, r)
		if err != nil {
			panic(err)
		}

		commitHash, err := getCommitHash(ctx, r)
		if err != nil {
			panic(err)
		}

		return r.WithExec([]string{
			"go", "build",
			"-ldflags",
			"-X 'github.com/prebid/prebid-server/version.Ver=" + tagVersion + "' -X 'github.com/prebid/prebid-server/version.Rev=" + commitHash + "'",
			"-o", "/src/prebid-server",
		})
	}
}

func WithExposePorts(ports ...int) dagger.WithContainerFunc {
	return func(r *dagger.Container) *dagger.Container {
		for _, port := range ports {
			r = r.WithExposedPort(port)
		}

		return r
	}
}

func compose(ctx context.Context, container *dagger.Container, args ...string) *dagger.File {
	actions := make([]dagger.WithContainerFunc, 0)

	for _, arg := range args {
		switch arg {
		case "install":
			actions = append(actions, WithGoInstallDependecies())
		case "test":
			actions = append(actions, WithGoTest())
		case "build":
			actions = append(actions, WithBuildBinary())
		case "vet":
			actions = append(actions, WithGoVet())
		}
	}

	for _, action := range actions {
		container = action(container)
	}

	return container.File("/src/prebid-server")
}

func main() {
	var actions string

	flag.StringVar(&actions, "actions", "install,vet,test,build", "action to run, e.g.: install,vet,test,build")

	flag.Parse()

	ctx := context.Background()
	client, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stdout))
	if err != nil {
		panic(err)
	}

	src := client.Host().Directory(".")

	ref := client.
		Container().
		From("golang:1.21").
		WithMountedDirectory("/src", src).
		WithWorkdir("/src")

	fileRef := compose(ctx, ref, strings.Split(actions, ",")...)

	_, err = client.Container().
		From("alpine:3.18").
		WithDefaultArgs(dagger.ContainerWithDefaultArgsOpts{
			Args: []string{"-v", "1", "-logtostderr"},
		}). // Set CMD to []
		With(WithExposePorts(80, 8080, 6060, 8100)).
		WithFile("/bin/prebid-server", fileRef).
		WithEntrypoint([]string{"/bin/prebid-server"}).
		Export(ctx, "./prebid-server.tar.gz")
	if err != nil {
		panic(err)
	}
}