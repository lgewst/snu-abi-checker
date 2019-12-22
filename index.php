<!DOCTYPE html>

<html lang="en">
<head>
        <title>WebOS</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
                table {
                    border-collapse: collapse;
					line-height: 1.5;
				    border-left: 1px solid #ccc;
				    margin: 20px 10px;
					text-align: center;
                }
                td {
					width: 250px;
					padding: 10px;
					font-weight: bold;
					vertical-align: top;
					border-right: 1px solid #ccc;
					border-bottom: 1px solid #ccc;
					background: #ececec;
				}
				th {
					padding: 10px;
					font-weight: bold;
					border-top: 1px solid #ccc;
				    border-right: 1px solid #ccc;
				    border-bottom: 2px solid #c00;
				    background: #dcdcd1;
				}
				body {
				    padding-left: 25px;
				}
				h1_div a {
					color: #eb4d8f;
				}
        </style>

</head>
<body>
        <h1>
			<h1_div>
				WebOS
			</h1_div>
			ABICC Report
			<!--
				<img src="webos.jpg" alt="webos" width="100">
			-->
		</h1>
        <h3>Report List</h3>

        <?php
                date_default_timezone_set("Asia/Seoul");

                // Reports Directory
                $dir = "/var/www/html";
		$reportname = "report.html";

                // Open directory
                $od = opendir($dir);

                // Reports in the dir
                $files = array();

                while(($filename = readdir($od))) {
                        if($filename == "." || $filename == "..") {
                                continue;
                        }

                        // Reports are html files.
                        if(is_file($dir . "/" . $filename) && strpos($filename, $reportname)) {
                                $files[] = $filename;
                        }
                }
                closedir($od);
                rsort($files);

                // Print Table
                echo "<table>";
                echo "<tr>";
                echo "<th>Date created</th>";
                echo "<th>Report name</th>";
                echo "</tr>";
                // Make href
                foreach($files as $f) {
                        echo "<tr>";
                        echo "<td>".date("Y-m-d H:i:s", filemtime($f))."</td>";
                        echo "<td><a href=./".$f.">".substr($f, 0, -5)."</a></td>";
                        echo "</tr>";
                }
                echo "</table>";
        ?>

		<?php
				$active = "enable";
				$dir = "/var/www/html";
	            $od = opendir($dir);
                
				while(($filename = readdir($od))) {
					if($filename == "active") {
                       $active = "disable";
                   }
                   else if ($filename == "inactive") {
						$active = "enable";
                   }
				}
				closedir($od);

				if (isset($_POST['disable'])) {
					$old_path = getcwd();
					chdir('/var/www/html');
					shell_exec('rm active');
					shell_exec('touch inactive');
					chdir($old_path);
					$active = "enable";
					echo "You have disabled automatic abi-checker";
				}
				
				if (isset($_POST['enable'])) {
					$old_path = getcwd();
					chdir('/var/www/html/');;
					shell_exec('rm inactive');
					shell_exec('touch active');
					chdir($old_path);
					$active = "disable";
					echo "You have enabled automatic abi-checker";
				}
        ?>

		<script type=text/javasript>
			function change() {
				var v = document.getElementById("toggles").innerHTML;
				if (v == "enable") {
					v = "disable";
				}
				else if (v == "disable") {
					v = "enable";
				}
				
				return true;
			}
		</script>
 
        <form method="post">
			WebOS build and ABICC run:
			<input type="submit" id="toggle" name="<?php echo $active; ?>" 
				value="<?php echo $active;?>" onClick="return change()"/>
		</form>

</body>
</html>

