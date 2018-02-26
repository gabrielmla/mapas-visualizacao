dsv2json  -r ',' -n < Matriculado_Ensino_Fundamental_na_Educao_Indgena-SEMREGIAO.csv > dado1-indigena-fundamental.ndjson
ndjson-split 'd.features' < geo1-br_municipios_projetado.json | ndjson-map 'd.GEOCODIGO = Number(d.properties.GEOCODIGO), d' > geo2-br_municipios_projetado.ndjson
ndjson-map 'd.GEOCODIGO = Number(d.GEOCODIGO), d' < dado1-indigena-fundamental.ndjson > dado2-indigena-fundamental.ndjson

EXP_PROPRIEDADE='d[0].properties = Object.assign({}, d[0].properties, d[1]), d[0]'
ndjson-join --left 'd.GEOCODIGO' \
  geo2-br_municipios_projetado.ndjson \
  dado2-indigena-fundamental.ndjson \
  | ndjson-map \
    "$EXP_PROPRIEDADE" \
  > geo3-municipios-e-ensino.ndjson
  
geo2topo -n \
  tracts=- \
< geo3-municipios-e-ensino.ndjson \
| toposimplify -p 1 -f \
| topoquantize 1e5 \
| topo2geo tracts=- \
> geo4-municipios-e-ensino-simplificado.json
