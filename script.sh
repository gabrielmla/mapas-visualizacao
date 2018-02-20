# Caso o npm install -g nao funcione
export PATH=$PATH:$HOME/node_modules/.bin/

# Transformar um arquivo .shp em um json com a geometria do mapa
shp2json 25SEE250GC_SIR.shp -o pb.json

# O mapa atual não está projetado, usamos geoproject para fazer a projecao das coordenadas do globo para coordenadas de um plano
geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json \
  > pb-ortho.json

# Gerando um svg das coordenadas para visualizacao
geo2svg \
  -w 1000 \
  -h 600 \
  < pb-ortho.json \
  > pb-ortho.svg

# Transformando o json com coordenadas projetadas em um ndjson
ndjson-split 'd.features' \
  < pb-ortho.json \
  > pb-ortho.ndjson

# Transformando os dados .csv em json
dsv2json \
  -r ';' \
  -n \
  < Pessoa01_PB.csv \
  > pb-censo.ndjson

# Mudando o nome de um campo para realizar um join em seguida
ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' \
  < pb-ortho.ndjson \
  > pb-ortho-sector.ndjson

# Join entre a geometria e os dados
ndjson-join 'd.Cod_setor' \
  pb-ortho-sector.ndjson \
  pb-censo.ndjson \
  > pb-ortho-censo-join.ndjson

# Modificando um campo para ter a variavel de interesse
ndjson-map \
  'd[0].properties = {responsaveis: Number(d[1].V078)}, d[0]' \
  < pb-ortho-censo-join.ndjson \
  > pb-ortho-comdado.ndjson

# Diminuindo o tamanho do arquivo
geo2topo -n \
  tracts=pb-ortho-comdado.ndjson \
  > pb-tracts-topo.json

toposimplify -p 1 -f \
  < pb-tracts-topo.json \
  | topoquantize 1e5 \
  > pb-quantized-topo.json
# Gerando a visualizacao com d3
topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 \
  'z = d3.scaleSequential(d3.interpolateViridis).domain([0, 530]), d.features.forEach(f => f.properties.fill = z(f.properties.responsaveis)), d' \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
  > pb-tracts-threshold-light.svg
