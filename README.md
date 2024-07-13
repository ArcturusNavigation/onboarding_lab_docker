# arcturus_docker

This code defines the development environment of all_seaing_vehicle via docker.

## Installation

First install `git` and Docker according to your OS:

- macOS: Make sure command line tools are installed by running `xcode-select --install` in a terminal and then [install and launch Docker Desktop](https://docs.docker.com/desktop/mac/install/). Open your [Docker preferences](https://docs.docker.com/desktop/mac/#preferences) and make sure Docker Compose V2 is enabled.
- Windows: [Install git](https://git-scm.com/download/win) and then [install and launch Docker Desktop](https://docs.docker.com/desktop/windows/install/).
- Linux: Make sure you have [git installed](https://git-scm.com/download/linux) and then [install Docker Engine for your distro](https://docs.docker.com/engine/install/#server) and install [Docker Compose V2](https://docs.docker.com/compose/cli-command/#install-on-linux).

Once everything is installed and running, if you're on macOS or Linux open a terminal and if you're on Windows open a PowerShell. Then clone and pull the image):

    git clone https://github.com/ArcturusNavigation/arcturus_docker.git
    cd arcturus_docker
    docker compose pull

Linux users may need to use `sudo` to run `docker compose`. The image is about 1GB compressed so this can take a couple minutes. Fortunately, you only need to do it once.

## Starting Up

Once the image is pulled you can start it by running the following in your `arcturus_docker` directory:

    docker compose up

Follow the instructions in the command prompt to connect via either a terminal or your browser.
If you're using the browser interface, click "Connect" then right click anywhere on the black background to launch a terminal.

Now you should have an Ubuntu Linux environment with ROS2 installed! However, note that you'll still need to clone all the required packages.

## Shutting Down

To stop the image, run:

    docker compose down

If you try to rerun `docker compose up` without first running `docker compose down` the image may not launch properly.

## Local Storage

Any changes made to the your home folder in the docker image (`/home/arcturus`) will be saved to the `arcturus_docker/home` directory your local machine but **ANY OTHER CHANGES WILL BE DELETED WHEN YOU RESTART THE DOCKER IMAGE**.

## Tips

- In the graphical interface, you can move windows around by holding <kbd>Alt</kbd> or <kbd>Command</kbd> (depending on your OS) then clicking and dragging *anywhere* on a window. Use this to recover your windows if the title bar at the top of a window goes off screen.
- You can edit files that are in the shared `home` directory using an editor on your host OS.

## Custom Builds

If you want to change the docker image and rebuild locally, all you need to do is add a `--build` flag:

    docker compose up --build
