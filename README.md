# helm-charts

## Add chart
```
helm init [name]
```

## Package chart
```
helm package [chart]
mkdir [chart location]
mv [chart-version.tgz] [chart location]/
helm repo index [chart location] --url https://chart.domain.com
```
