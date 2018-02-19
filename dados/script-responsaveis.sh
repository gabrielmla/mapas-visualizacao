#!/bin/bash
dados="/home/gabriel/Documents/github/mapa-ninja/dados/PB/CSV/Pessoa01_PB.csv"
# a expressão javascript que cria a variável a plotar
d3Property='d[0].properties = {filhos_enteados_alfa: Number(d[1].V080)}, d[0]'
# a expressão js que decide os fills baseados em uma escala
d3Scale='z = d3.scaleThreshold().domain([0, 150, 300, 450, 600]).range(d3.schemePurples[5]), d.features.forEach(f => f.properties.fill = z(f.properties.filhos_enteados_alfa)), d'

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

echo "Gerando a visualizacao com d3"
ndjson-map \
  "$d3Property" \
  < pb-ortho-censo-join.ndjson \
  | geo2topo -n \
    tracts=- \
  | toposimplify -p 1 -f \
  | topoquantize 1e5 \
  | topo2geo tracts=- \
  | ndjson-map -r d3 -r d3=d3-scale-chromatic \
    "$d3Scale" \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
    > pb-responsaveis-filhos-alfabetizados.svg