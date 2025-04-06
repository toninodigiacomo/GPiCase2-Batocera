#!/bin/bash

###############################################################################
# Script d'installation pour le script Python de Safe Shutdown RetroFlag
# Amélioré avec gestion d'erreurs, messages explicites et nettoyage final
###############################################################################

# Nettoyage de l'écran
clear
echo "=========================================================="
echo " Début du script d'installation du Safe Shutdown RetroFlag"
echo "=========================================================="

# Définir les chemins
SourcePath="/userdata/system/GPiCase2-Batocera-Batocera40_SafeShutdown_GPi2_v1.3"
InstallDir="/userdata/RetroFlag"
ScriptName="SafeShutdown_lcd_dock.py"
OriginalScript="Batocera40_SafeShutdown_GPi2.py"
ScriptPath="$InstallDir/$ScriptName"
CustomSh="/userdata/system/custom.sh"
UserDir="$PWD"

# Petite pause pour lisibilité
sleep 2s

# Remonter les partitions en lecture/écriture
echo "[INFO] Remontée de /boot et / en lecture/écriture..."
mount -o remount, rw /boot || { echo "[ERREUR] Impossible de remonter /boot en RW"; exit 1; }
mount -o remount, rw / || { echo "[ERREUR] Impossible de remonter / en RW"; exit 1; }

# Création du répertoire d'installation
echo "[INFO] Vérification du répertoire $InstallDir..."
if [ -d "$InstallDir" ]; then
    echo "[AVERTISSEMENT] Le répertoire $InstallDir existe déjà. Le contenu pourrait être écrasé."
else
    mkdir -p "$InstallDir" || { echo "[ERREUR] Impossible de créer $InstallDir"; exit 1; }
    echo "[INFO] Répertoire $InstallDir créé avec succès."
fi
sleep 2s

# Vérifier que le script source existe
if [ ! -f "$SourcePath/$OriginalScript" ]; then
    echo "[ERREUR] Le script source $SourcePath/$OriginalScript est introuvable."
    exit 1
fi

# Déplacer le script Python
echo "[INFO] Déplacement du script Python dans $InstallDir..."
mv "$SourcePath/$OriginalScript" "$ScriptPath" || { echo "[ERREUR] Échec du déplacement du script"; exit 1; }

# Vérification de custom.sh
echo "[INFO] Configuration du script de démarrage $CustomSh..."

if grep -q "python $ScriptPath &" "$CustomSh"; then
    echo "[INFO] Entrée déjà présente dans custom.sh."
else
    echo "python $ScriptPath &" >> "$CustomSh" || { echo "[ERREUR] Impossible d'écrire dans $CustomSh"; exit 1; }
    echo "[INFO] Entrée ajoutée dans custom.sh."
fi

# S'assurer que custom.sh est exécutable
if [ ! -x "$CustomSh" ]; then
    chmod +x "$CustomSh" || { echo "[ERREUR] Impossible de rendre $CustomSh exécutable"; exit 1; }
    echo "[INFO] Script custom.sh rendu exécutable."
else
    echo "[INFO] custom.sh est déjà exécutable."
fi

# Nettoyage final
echo "[INFO] Nettoyage du répertoire temporaire..."
cd "$UserDir" || { echo "[ERREUR] Impossible de retourner dans $UserDir"; exit 1; }
rm -rf "$SourcePath" || echo "[AVERTISSEMENT] Impossible de supprimer $SourcePath (ce n'est pas bloquant)."

# Fin du script
echo "=========================================================="
echo " Installation terminée avec succès."
echo " Redémarrage dans 3 secondes..."
echo "=========================================================="
sleep 3
shutdown -r now
