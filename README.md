# local-mesh
This is a lightweight way to test Envoy side-car with a service.
It makes uses of docker's network_mode=container to work.

## POD
The docker-compose.yaml file in the pod directory is the parent container which gets the a real docker ip address. It also implements the iptable rules for re-routing the traffic to the Envoy sidecar.
It needs to be launched first with
```sh
docker-compose up --build --remove-orphans
```

## Envoy and Service (httpbin)
Once the pod bootstrap docker container is up, then bring up the Envoy and Service containers within the container network of bootstrap container with
```sh
docker-compose up
```

## Validate Routing
Execute
```sh
curl -X GET 127.0.0.1:8000/headers
```
You should be able to see Envoy response headers in the output
```json
{
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "127.0.0.1",
    "User-Agent": "curl/7.68.0",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-Request-Id": "955e1da9-4b1f-4e64-a198-40195406cfa7"
  }
}

```


