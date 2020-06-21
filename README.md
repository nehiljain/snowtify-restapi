


# snowtify-api



1. Get alerts when there are runaway queries in last 1 hour


- Airflow DBT runs
  - built snowflake query performance metrics

Data Base Design
- query_performance_metrics

- alerts
  - alert_config_id
  - name
  - created_at
  - status
  - metadata
  - description

- alert_configs
  - id (foreign key alerts.alert_config_id)
  - slack_channel
  - slack_message

- monitors
  - type
    - query credit quota
    - runnaway query
    - query sla
    - clustering credits quota
    - materialized view credits quota
    - snowpipe credit quota
  - credits_used
  - name
  - credit_quota
  - frequency
  - start_time
  - end_time
  - notify_threshold
  - created_at
  - created_by
  - owner
  - comment



API Design
- alerts


-----


# Dockerizing Flask with Postgres, Gunicorn, and Nginx

## Want to learn how to build this?

Check out the [post](https://testdriven.io/blog/dockerizing-flask-with-postgres-gunicorn-and-nginx).

## Want to use this project?

### Development

Uses the default Flask development server.

1. Rename *.env.dev-sample* to *.env.dev*.
1. Update the environment variables in the *docker-compose.yml* and *.env.dev* files.
1. Build the images and run the containers:

    ```sh
    $ docker-compose up -d --build
    ```

    Test it out at [http://localhost:5000](http://localhost:5000). The "web" folder is mounted into the container and your code changes apply automatically.

### Production

Uses gunicorn + nginx.

1. Rename *.env.prod-sample* to *.env.prod* and *.env.prod.db-sample* to *.env.prod.db*. Update the environment variables.
1. Build the images and run the containers:

    ```sh
    $ docker-compose -f docker-compose.prod.yml up -d --build
    ```

    Test it out at [http://localhost:1337](http://localhost:1337). No mounted folders. To apply changes, the image must be re-built.
