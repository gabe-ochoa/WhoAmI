# Who am I?
[ ![Codeship Status for gabe-ochoa/WhoAmI](https://app.codeship.com/projects/43ec8010-dec2-0134-f6d9-669b3eb0e523/status?branch=master)](https://app.codeship.com/projects/204740)

Yes, who are you.

A small Etcd backed Sinatra based service for dishing out unique hostnames to machines that are booted with possible conflicting hostnames.

For example, if you were running a Kubernetes Raspberry Pi cluster and need the workers to get a unique hostname when they were added to the cluster, but only wanted to use one SD card image to make it easy to replace / add workers.

## API

### /health
```
/health
```
```
"I'm alive!"
```

### /hostname
The host name endpoint takes 2 parameters - a MAC address (required) and a service (default: 'kubernetes') - and returns a hostname.
```
/hostname?mac=01:02:03:04:05:06&service=wink-tv
```
'wink-tv-1'
```
