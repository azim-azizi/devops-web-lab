# Azim's DevOps Lab

I wanted to learn how to build and run a container on Linux. I used Podman and NGINX on an Ubuntu VM in VMware Workstation to serve a simple HTML page.

## Files

- `index.html` is the page I made.
- `nginx.conf` tells NGINX to listen on port 80 and serve the page from `/srv/devops-lab`.
- `Containerfile` copies both files into the image.

### Containerfile

```dockerfile
FROM public.ecr.aws/nginx/nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /srv/devops-lab/index.html
```

### nginx.conf

```nginx
events {}

http {
    include /etc/nginx/mime.types;

    server {
        listen 80;
        root /srv/devops-lab;
        index index.html;
    }
}
```

## How I ran it

I ran these commands in Ubuntu with Podman and curl installed. The dot at the end of the build command tells Podman to use the current folder.

```bash
cd ~/devops-web-lab &&
podman build -t localhost/azim-web:latest . &&
podman run --rm localhost/azim-web:latest nginx -t &&
podman run -d --replace --name azim-web -p 127.0.0.1:8080:80 localhost/azim-web:latest
```

Port 8080 on the Ubuntu VM forwards to port 80 in the container. I opened [http://127.0.0.1:8080/](http://127.0.0.1:8080/) in Firefox inside the VM and saw **Azim's DevOps Lab**. I also checked the heading from the terminal.

```bash
curl -fsS http://127.0.0.1:8080/ | grep -F '<h1>'
```

```html
<h1>Azim's DevOps Lab</h1>
```

## What went wrong

My first build was missing the dot at the end, and I had saved the file as `ContainerFile`. I fixed both. I also typed `alphine` instead of `alpine`. After correcting the tag, Docker Hub still denied the download, so I pulled the NGINX image from Amazon ECR Public.

The first page I got was the NGINX welcome page. I had copied my HTML to `/user/share/`, so NGINX didn't pick it up. I changed the setup to use `/srv/devops-lab` in both the Containerfile and the NGINX config.

Later, curl couldn't connect. I ran `podman ps -a` and saw that the container had exited. The logs showed a missing semicolon after `listen 80`. Another test caught `event` on the first line, which should have been `events`. After fixing the config, I rebuilt the image, ran `nginx -t`, and started the container when the test passed. Then I checked the page again with curl and Firefox.
