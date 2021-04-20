echo Creating Ceylan consoles...

konsole --workdir $CEYLAN_SRC/.. --name trunk &
konsole --workdir $CEYLAN_SRC/conf/build --name build &
konsole --workdir $CEYLAN_SRC --name src &
konsole --workdir $CEYLAN_SRC/../test --name test &
