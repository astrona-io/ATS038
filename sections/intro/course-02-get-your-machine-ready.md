# Get Your Machine Ready

Every playground and lab in this course runs on your own machine, in a small Kubernetes cluster. A tool called `astrona` builds it for you, sets it up, grades your work and removes it again. This page gets your machine ready: first the tools you need, then the handful of `astrona` commands you will use every day, and last what to do when a start goes wrong.

## What you need

Every section needs the same set of tools. Install these before you start:

- **A container engine:** Docker or Podman. The cluster runs inside it.
- **`kind`:** runs Kubernetes inside the container engine.
- **`kubectl`:** talks to the cluster. You use it on every page.
- **The astrona command-line tool.**
- **`jq`:** reads the JSON that `kubectl` prints, so you can pick out one field.

The playgrounds and labs also need **outbound internet** while they start, to download their container images. Without it, a start fails with network errors that have nothing to do with the topic of the module.

You do not have to check all of this by hand. Let `astrona` look at your machine for you:

```sh
astrona setup
```

`astrona setup` looks at what is missing, shows each step it would take, and asks before it does anything. Later, you can check your machine at any time:

```sh
astrona check
```

## The commands you use every day

Once your machine is ready, you need only a handful of `astrona` commands. Each module page and lab page shows the exact command to copy. This section walks through them in the order you meet them: sign in, start, submit and clean up.

Labs from the course catalog are tied to your Astrona account, so you sign in first:

```sh
astrona login
```

Next you start a playground or a lab. It looks like this:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-01/playground
```

When the cluster is ready, `kubectl` already points at it. Inside a lab, you send your work for grading with `astrona submit`. The grader checks the live cluster, so your change has to work, not only make an error message go away. You can submit as often as you like:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When you are done with a playground or a lab, remove it:

```sh
astrona destroy <name>
```

The name is the environment's name, printed by `astrona run` and shown on each page (for example `ats-038-playground-010-01`). It is not the folder path. To see what is on your machine, list it:

```sh
astrona list
```

> [!WARNING]
> **Run one environment at a time.** Each playground and lab is a whole cluster. Two running at once slow your machine down, and it is easy to send a command to the wrong one.

## When a start goes wrong

Sometimes a playground or lab does not start cleanly. Ask `astrona` what is wrong before you try anything else:

```sh
astrona doctor
```

It checks your machine, the lab's configuration and the running lab, and tells you how to fix what it finds. If a start fails while it downloads something, check your network first. Remember also that many playgrounds and labs start with something broken on purpose: the module's landing page tells you when that is the case. With your machine ready and these commands at hand, you can start the first module.
