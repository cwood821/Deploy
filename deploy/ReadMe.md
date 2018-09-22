# Deploy

Drop-in `rsync` deployment for small projects.

# Assumptions
- You have passwordless SSH configured for your server

# Usage 
- Add your SSH, server, and project information to the provided `.env` file
- Make the `deploy.sh` file executable
- Run `./deploy.sh` in your project's directory

# Bonus
- Rsync output is logged to a directory you specify in the `.env` file.
- Run a script or command pre-deployment adding its path to the `PRE_DEPLOYMENT_SCRIPT` variable in the `.env` file
