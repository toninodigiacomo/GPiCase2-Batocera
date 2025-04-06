Ne pas utiliser ***system.power.switch=RETROFLAG_GPI***

- Copier les fichiers ***Batocera40_SafeShutdown_GPi2.py*** et ***Batocera40_Install_GPi2.sh*** sur la carte SD.
- Rendre le fichier _Batocera40_Install_GPi2.sh_ executable : __chmod +x Batocera40_Install_GPi2.sh__
- Lancer le script.

Ou bien:
- Télécharger l'archive :
```
wget https://github.com/toninodigiacomo/GPiCase2-Batocera/archive/refs/tags/Batocera40_SafeShutdown_GPi2_v1.0.zip
```
- Décompresser l'archive :
```
unzip Batocera40_SafeShutdown_GPi2_v1.0.zip; rm Batocera40_SafeShutdown_GPi2_v1.0.zip
```
- Changer de répertoire :
```
cd GPiCase2-Batocera-Batocera40_SafeShutdown_GPi2_v1.0
```
- Rendre le fichier _Batocera40_Install_GPi2.sh_ executable : 
```
chmod +x Batocera40_Install_GPi2.sh
```
- Executer le script : 
```
sh ./Batocera40_Install_GPi2.sh
```


source: https://www.reddit.com/r/batocera/comments/1fdcr3u/batocera_retroflag_gpi_case2_dock_working/
