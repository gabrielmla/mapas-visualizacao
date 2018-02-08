export PATH=$PATH:./node_modules/.bin/

shp2json 25SEE250GC_SIR -o pb.json

geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json \
  > pb-ortho.json

geo2svg \
  -w 1000 \
  -h 600 \
  < pb-ortho.json \
  > pb-ortho.svg

ndjson-split 'd.features' \
  < pb-ortho.json \
  > pb-ortho.ndjson

dsv2json \
  -r ';' \
  -n \
  < Pessoa01_PB.csv \
  > pb-censo.ndjson

ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' \
  < pb-ortho.ndjson \
  > pb-ortho-sector.ndjson

ndjson-join 'd.Cod_setor' \
  pb-ortho-sector.ndjson \
  pb-censo.ndjson \
  > pb-ortho-censo-join.ndjson

V078 V080
ndjson-map \
  'd[0].properties = {responsaveis: Number(d[1].V078)}, d[0]' \
  < pb-ortho-censo-join.ndjson \
  > pb-ortho-comdado.ndjson

geo2topo -n \
  tracts=pb-ortho-comdado.ndjson \
  > pb-tracts-topo.json

toposimplify -p 1 -f \
  < pb-tracts-topo.json \
  | topoquantize 1e5 \
  > pb-quantized-topo.json

topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 \
  'z = d3.scaleSequential(d3.interpolateViridis).domain([0, 1e3]), d.features.forEach(f => f.properties.fill = z(f.properties.responsaveis)), d' \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
  > pb-tracts-threshold-light.svg
