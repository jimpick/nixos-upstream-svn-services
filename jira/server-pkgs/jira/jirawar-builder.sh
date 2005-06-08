set -e

. $stdenv/setup

tar zxvf  $src
cd atlassian-*

# todo: make this a plugin that installs the libraries an manipulates the entityengine datasource?
echo "postgresql: $postgresql"
cp $postgresql/share/java/postgresql.jar webapp/WEB-INF/lib

#todo: this should definitly be a plugin
cp $extrajars/*.jar webapp/WEB-INF/lib

plugins=($plugins)
i=0
while [ "$i" -lt "${#plugins[*]}" ]
do
  echo FOO $i "${#plugins[*]}"
  plugin=${plugins[i]}
  . ${plugin_installers[i]}
  i=`expr $i + 1`
done

cat > edit-webapp/WEB-INF/classes/entityengine.xml <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE entity-config PUBLIC "-//OFBiz//DTD Entity Engine Config//EN" "http://www.ofbiz.org/dtds/entity-config.dtd">
<entity-config>
  <resource-loader name="maincp" class="org.ofbiz.core.config.ClasspathLoader"/>

  <transaction-factory class="org.ofbiz.core.entity.transaction.JotmFactory"/>

  <delegator name="default" entity-model-reader="main" entity-group-reader="main">
    <group-map group-name="default" datasource-name="defaultDS"/>
  </delegator>

  <entity-model-reader name="main">
    <resource loader="maincp" location="entitydefs/entitymodel.xml"/>
  </entity-model-reader>

  <entity-group-reader name="main" loader="maincp" location="entitydefs/entitygroup.xml"/>

  <field-type name="cloudscape" loader="maincp" location="entitydefs/fieldtype-cloudscape.xml"/>
  <field-type name="firebird" loader="maincp" location="entitydefs/fieldtype-firebird.xml"/>
  <field-type name="hsql" loader="maincp" location="entitydefs/fieldtype-hsql.xml"/>
  <field-type name="mckoidb" loader="maincp" location="entitydefs/fieldtype-mckoidb.xml"/>
  <field-type name="mysql" loader="maincp" location="entitydefs/fieldtype-mysql.xml"/>
  <field-type name="mssql" loader="maincp" location="entitydefs/fieldtype-mssql.xml"/>
  <field-type name="oracle" loader="maincp" location="entitydefs/fieldtype-oracle.xml"/>
  <field-type name="postgres" loader="maincp" location="entitydefs/fieldtype-postgres.xml"/>
  <field-type name="postgres72" loader="maincp" location="entitydefs/fieldtype-postgres72.xml"/> <!-- use for postgres 7.2 and above -->
  <field-type name="sapdb" loader="maincp" location="entitydefs/fieldtype-sapdb.xml"/>
  <field-type name="sybase" loader="maincp" location="entitydefs/fieldtype-sybase.xml"/>

  <datasource name="defaultDS"
    schema-name="public" 
    helper-class="org.ofbiz.core.entity.GenericHelperDAO"
    check-on-start="true"
    use-foreign-keys="false"
    use-foreign-key-indices="false"
    check-fks-on-start="false"
    check-fk-indices-on-start="false"
    add-missing-on-start="true"
    check-indices-on-start="true"
    field-type-name="postgres72">
    <inline-jdbc
      jdbc-driver="org.postgresql.Driver"
      jdbc-uri="jdbc:postgresql://$host:$port/$database"
      jdbc-username="$username"
      jdbc-password="$password"
      isolation-level="Serializable"/>
  </datasource>
</entity-config>
EOF

echo $ant
$ant/bin/ant

ensureDir $out/bin
ensureDir $out/lib
cp dist-generic/atlassian-jira-$version.war $out/lib/atlassian-jira.war

cat > $out/bin/init-database <<EOF
#! $SHELL
echo "Checking for user $username."
echo "If a password is required, then you must enter the password \"$password\" for the database user $username"
if $postgresql/bin/psql -U $username -l
then
  echo "User $username exists in PostgreSQL database cluster. Great."
else
  echo "User $username does not exist in PostgreSQL database cluster. I'm going to create this user for you."
  echo "I'll do this as the postgres user."
  $postgresql/bin/createuser -A -D -U postgres -h $host -p $port $username
fi

echo "Checking for database $database."
if ( $postgresql/bin/psql -U $username -l | grep $database > /dev/null )
then
  echo "Database $database seems to exist. Great."
else
  echo "Database $database does not exist. I'm going to create this database for you."
  echo "I'll do this as the postgres user."
  $postgresql/bin/createdb -U postgres -h $host -p $port -O $username $database
fi
EOF

cat > $out/bin/control <<EOF
#! $SHELL

if test "\$1" = jira-init; then

    createuser --no-createdb --no-adduser -p $port owner
    createdb -p $port -O owner jira

fi

EOF

chmod +x $out/bin/*
