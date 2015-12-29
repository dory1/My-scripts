#!/usr/bin/perl

# PERL MODULES WE WILL BE USING
use DBI;
use DBD::mysql;

# CONFIG VARIABLES
$platform = "mysql";
$database = "radius";
$host = "localhost";
$port = "3306";
$tablename = "RADONLINE";
$user = "USERNAME";
$pw = "PASSWORD";

# DATA SOURCE NAME
$dsn = "dbi:mysql:$database:localhost:mysql_socket=/mysql_data/55/mysql.socket";

# PERL DBI CONNECT
$connect = DBI->connect($dsn, $user, $pw, {HandleError => \&dbi_error_handler});

# PREPARE THE QUERY
$query = "select count(*) as count from RADONLINE WHERE FROM_UNIXTIME(TIME_STAMP) > DATE_SUB( NOW(), INTERVAL 5 minute)";
$query_handle = $connect->prepare($query) ;


# EXECUTE THE QUERY
$query_handle->execute()  ;

# BIND TABLE COLUMNS TO VARIABLES
$query_handle->bind_columns(undef, \$count);

# LOOP THROUGH RESULTS
while($query_handle->fetch()) {
	if ($count == 0)
	{
	print "No conn in the last 5 min!\n";
	exit(2);
	}
	else
	{
	print "Radius is OK\n"
	}
} 

sub dbi_error_handler
{
print "Error while trying to query the database! DATABASE NOT AVAILABLE! \n";
exit(2);
}
