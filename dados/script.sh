dados="/home/gabriel/Documents/github/mapa-ninja/dados/PB/CSV/Pessoa01_PB.csv"
d3Property='d[0].properties = {responsaveis: Number(d[1].V078)}, d[0]'
d3Scale='z = d3.scaleSequential(d3.interpolateViridis).domain([0, 530]), d.features.forEach(f => f.properties.fill = z(f.properties.responsaveis)), d'

echo "Transformando os dados .csv em json"
dsv2json \
  -r ';' \
  -n \
  < $dados \
  > pb-censo.ndjson

echo "Join entre a geometria e os dados"
ndjson-join 'd.Cod_setor' \
  pb-ortho-sector.ndjson \
  pb-censo.ndjson \
  > pb-ortho-censo-join.ndjson

echo "Modificando um campo para ter a variavel de interesse"
ndjson-map \
  "$d3Property" \
  < pb-ortho-censo-join.ndjson \
  > pb-ortho-comdado.ndjson

echo "Diminuindo o tamanho do arquivo"
geo2topo -n \
  tracts=pb-ortho-comdado.ndjson \
  > pb-tracts-topo.json

toposimplify -p 1 -f \
  < pb-tracts-topo.json \
  | topoquantize 1e5 \
  > pb-quantized-topo.json

echo "Gerando a visualizacao com d3"
topo2geo tracts=- \
  < pb-quantized-topo.json \
  | ndjson-map -r d3 \
  "$d3Scale" \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
  > pb-tracts-responsaveis.svg

echo "DONE."
