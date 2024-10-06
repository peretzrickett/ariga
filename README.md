md
# GitHub Runner with PostgreSQL and Atlas Integration

This project provides a development environment for setting up a self-hosted GitHub Runner that interacts with PostgreSQL via Docker, Supervisor, and Atlas. The runner is pre-configured to support database testing and schema management workflows using Ariga's Atlas.

## Setup Development Environment

### Prerequisites
Ensure you have the following installed on your host system:
- Docker
- Docker Compose

### Steps to Set Up the Environment

1. **Create a `.env` File**  
   In the root directory of your project, create a `.env` file with the following environment variables. These are essential for configuring your GitHub Runner and Atlas.

   ```bash
   # .env file
   RUNNER_TOKEN=your_github_runner_token
   REPO_URL=https://github.com/your_username/your_repo
   ATLAS_TOKEN=your_atlas_token

- `RUNNER_TOKEN`: The token you retrieve from GitHub to register the runner. Go to your repository settings under **Actions** -> **Runners** and generate a token.
- `REPO_URL`: The repository URL where the runner will be attached.
- `ATLAS_TOKEN`: The token for Atlas, if needed for managing schema migrations.

2. **Start the Containers**  
   Once the `.env` file is set up, run the following command to start the containers in detached mode:

   ```bash
   docker-compose up -d
   ```

   This will:
   - Spin up a PostgreSQL container (`my_postgres`) with a predefined schema.
   - Start a GitHub Runner container (`github-runner`) that connects to your GitHub repository and runs with Supervisor for process management.

3. **Verify the GitHub Runner is Attached**  
   Navigate to your GitHub repository's **Settings** -> **Actions** -> **Runners**. You should see a runner named `my_runner` (or your preferred runner name) attached to your repository and available to execute CI jobs.

4. **Understanding Supervisor's Role**  
   The GitHub Runner container uses Supervisor as the process manager to:
   - Start `dockerd` (Docker Daemon) within the container.
   - Register and run the GitHub runner service.

   This setup ensures that the runner has its own Docker daemon to execute containerized jobs independently of the host system’s Docker.

5. **Atlas Pre-Configured**  
   The Dockerfile has been pre-configured with Atlas installed to speed up build times. This allows Atlas to manage database schema changes and ensure smooth schema versioning across environments.

6. **Database Initialization**  
   The PostgreSQL database (`my_postgres`) is initialized with the schema defined in `src/initdb.sql`. The container auto-populates the database upon startup.

### Notes on Dockerfile and docker-compose.yml

- The Dockerfile ensures that both Docker and Supervisor are properly configured inside the `github-runner` container.
- `docker-compose.yml` orchestrates the runner and PostgreSQL containers. The runner container includes the setup to connect automatically to the GitHub repository with Supervisor managing the runner's lifecycle.
- The initialization script in `src/initdb.sql` seeds the PostgreSQL database with sample schema and data on container startup.

## Description of Workflows

### 1. **CI-test.yml**  

This workflow runs unit tests on the database. Each test populates the database with test data, performs checks on triggers, and validates expected outcomes. The `atlas schema test` command ensures that schema changes are validated against your database.

- **Trigger**: Automatically runs on each push to any branch.
- **Atlas Integration**: Runs schema tests with Atlas.

### 2. **CI-apply.yml**  

This workflow applies any database schema changes to the main PostgreSQL instance after the PR is approved and merged.

- **Trigger**: Runs when a pull request is approved and merged into the main branch.
- **Atlas Integration**: Applies schema changes using Atlas's `atlas schema apply` command.

---
For more details on each command used, refer to the respective documentation for [GitHub Actions](https://docs.github.com/en/actions), [Atlas](https://atlasgo.io/), and [PostgreSQL](https://www.postgresql.org/).
