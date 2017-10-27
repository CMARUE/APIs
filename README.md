# APIfication de la BDCOM et du PLU parisiens pour [CMARUE](https://cmarue.fr)

L'application CMARUE utilise notamment deux bases de données ouvertes en open data par la Ville de Paris : la [BDCOM](https://opendata.paris.fr/explore/dataset/commercesparis/information) (base de données des commerces de la Ville, pour récupérer le nombre de commerces d'un type donné dans un rayon défini autour d'un point) et le [PLU](https://opendata.paris.fr/explore/dataset/plu-protection-du-commerce-et-de-lartisanat/information/) (Plan local d'urbanisme) pour déterminer si une adresse fait l'objet d'une mesure particulière de protection commerciale ou artisanale.

Ce repo présente le code utilisé pour créer des API à partir de ces jeux de données dans le cadre spécifique de leur utilisation pour CMARUE. Une alternative aurait peut-être été d'utiliser les API proposées par le portail https://opendata.paris.fr. 

### Attribution des données 

- Plan Local d'urbanisme - Mairie de Paris , sous license ODbL
- Base des commerces Parisiens - Mairie de Paris , sous license ODbL

### Licence du code

Ce code est placé sous licence [GNU LGPLv3](https://choosealicense.com/licenses/lgpl-3.0/). 
