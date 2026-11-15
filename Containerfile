FROM public.ecr.aws/nginx/nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /srv/devops-lab/index.html
