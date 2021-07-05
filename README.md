# Plio load testing
This repository is responsible for

## Installation
```sh
docker pull loadimpact/k6
```

```sh
docker run -i loadimpact/k6 run - <script.js
```

```sh
docker run -i loadimpact/k6 run --vus 10 --duration 30s - <script.js
```
