# Deploy
Drop-in `rsync` deployment for small projects. Originally developed as a lightweight option for small, static sites.

# Assumptions
- You have passwordless SSH configured for your server

# Usage 
- Add your SSH, destination server, and project information to the provided `.env` file
- Make the `deploy.sh` file executable
- Run `./deploy.sh` in your project's directory

# Features
- Supports pre and post-deployment script execution for build, cleanup, or other tasks (define them in the `.env` file)
- Checks for a 200 response from the destination web server post-deployment
- Rsync output is logged to a directory you specify in the `.env` file.