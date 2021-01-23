#!/bin/sh

echo "## Step 1: Install dependencies"
sleep 1
sudo apt-get update
sudo apt-get install -y libsndfile1-dev git
sudo apt-get install -y imagemagick libfftw3-dev
sudo apt-get install -y ffmpeg 

# We use CSDR as a dsp for analogs modes thanks to HA7ILM
git clone https://github.com/F5OEO/csdr
cd csdr || exit
make && sudo make install
cd ../ || exit

cd src || exit
git clone https://github.com/F5OEO/librpitx
cd librpitx/src || exit
make
cd ../../ || exit

cd pift8
git clone https://github.com/kgoba/ft8_lib
cd ../

make
sudo make install
cd .. || exit

printf "\n\n"
echo "The apt-spoofer TX side uses the GPU to drive the transmission."
echo "When the GPU frequency changes (i.e. undervolting), so does the" 
echo "transmission, causing it to malfunction."
echo " "
echo "Prevent mentioned issue and set the GPU frequency to 250 MHz?"
printf "[y/n] "
read -r CONT

if [ "$CONT" = "y" ]; then
  echo "Setting GPU frequency to 250 MHz."
   LINE='gpu_freq=250'
   FILE='/boot/config.txt'
   grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"
   #PI4
   LINE='force_turbo=1'
   grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"
   echo "Setup completed for the TX side"
else
  echo "### WARNING: TX will malfunction if your Raspberry Pi";
  echo "### is undervolted. BE CAREFUL!"
fi
echo "## Step 2: Setup the signal encoder"