sudo apt-get autoremove sqlite3
sudo apt-get install python-software-properties
sudo apt-add-repository -y ppa:travis-ci/sqlite3
sudo apt-get -y update
sudo apt-cache show sqlite3
sudo apt-get install sqlite3=3.7.15.1-1~travis1
sudo sqlite3 -version