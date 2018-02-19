echo "Instalando dependencias"
npm install

echo "Caso o npm install -g nao funcione"
export PATH=$PATH:./node_modules/.bin/

echo "Transformar um arquivo .shp em um json com a geometria do mapa"
shp2json 25SEE250GC_SIR.shp -o pb.json

echo "O mapa atual não está projetado, usamos geoproject para fazer a projecao das coordenadas do globo para coordenadas de um plano"
geoproject \
  'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
  < pb.json \
  > pb-ortho.json

echo "Gerando um svg das coordenadas para visualizacao"
geo2svg \
  -w 1000 \
  -h 600 \
  < pb-ortho.json \
  > pb-ortho.svg

echo "Transformando o json com coordenadas projetadas em um ndjson"
ndjson-split 'd.features' \
  < pb-ortho.json \
  > pb-ortho.ndjson

echo "Mudando o nome de um campo para realizar um join em seguida"
ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' \
  < pb-ortho.ndjson \
  > pb-ortho-sector.ndjson

echo "DONE."
