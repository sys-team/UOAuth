<!DOCTYPE html>

<html>

    <head>
        <title>Unact login</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href='http://fonts.googleapis.com/css?family=Didact+Gothic&subset=latin,cyrillic' rel='stylesheet' type='text/css'>
        <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
        
        <style>
            .button-image{
                max-height: 100px;
                max-width: 300px;
            }
            
            .lead {
                text-shadow: #FFFFFF 1px 1px 1px;
                line-height: 40px;
            }
            
            .thumbnail {
                border: 1px solid #aaa;
                -webkit-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
                -moz-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
            }
            
            a.thumbnail:hover {
                -webkit-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
                -moz-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
                box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
            }
        </style>
        
        <script src="bootstrap/js/bootstrap.min.js"></script>
        
    </head>
    
    <body>
        
        <?php 
            $u_auth_server_url = "https://system.unact.ru/oauth/handler/auth";
            $client_id = $_REQUEST["client_id"];
            
            if	($client_id == ""){
            echo "<div class='alert alert-error'>
                        <strong>Error!</strong> No client ID provided
                    </div>";
            die();
            }
        ?>
        
        <div class = "container">
            <div class="row">
                <div class="span4"></div>
                <div class="span3">	
                    <ul class="thumbnails">
                        <li class="span3"><p class="lead">Войти&nbsp;с&nbsp;помощью</p></li>
                        <li class="span3">
                            <a class="thumbnail" href="https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile&redirect_uri=<?php echo $u_auth_server_url;?>/google/<?php echo $client_id;?>&response_type=code&client_id=1043543321098-pp8ltrn0oqnrattumr2ukmc57svpp555.apps.googleusercontent.com">
                                <img src="img/google-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li class="span3">
                            <a class="thumbnail" href="https://www.facebook.com/dialog/oauth?client_id=280478078728915&redirect_uri=<?php echo $u_auth_server_url;?>/facebook/<?php echo $client_id;?>">
                                <img src="img/facebook-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li class = "span3">
                            <a class="thumbnail" href="http://oauth.vk.com/authorize?client_id=3141555&scope=status&redirect_uri=<?php echo $u_auth_server_url;?>/vk/<?php echo $client_id;?>&response_type=code">
                                <img src="img/vk-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li class="span3"><small>>ЮНЭКТ Группа компаний</small></li>
                    </ul>
                </div>
            </div>    
        </div>
        
    </body>
    
</html>