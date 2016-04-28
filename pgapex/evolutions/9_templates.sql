INSERT INTO pgapex.template (template_id, name) VALUES (1, 'Login page');
INSERT INTO pgapex.template (template_id, name) VALUES (2, 'Normal page');
INSERT INTO pgapex.template (template_id, name) VALUES (3, 'Top navigation template');
INSERT INTO pgapex.template (template_id, name) VALUES (4, 'Region template');
INSERT INTO pgapex.template (template_id, name) VALUES (5, 'Navigation region template');


INSERT INTO pgapex.navigation_template (template_id, navigation_begin, navigation_end) VALUES (3, '<ul class="nav navbar-nav">', '</ul>');
INSERT INTO pgapex.navigation_item_template (navigation_item_template_id, navigation_template_id, active_template, inactive_template, level) VALUES (1, 3, '<li class="active"><a href="#URL#">#NAME#</a></li>', '<li><a href="#URL#">#NAME#</a></li>', 1);


INSERT INTO pgapex.page_template (template_id, page_type_id, header, body, footer, error_message, success_message) VALUES (1, 'LOGIN', '<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#TITLE#</title>

    <!-- Bootstrap core CSS -->
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>', '  <body>
    <nav class="navbar navbar-inverse">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="#">#APPLICATION_NAME#</a>
        </div>
      </div>
    </nav>


    <div class="container">
      #SUCCESS_MESSAGE#
      #ERROR_MESSAGE#
      <div class="alert alert-success" role="alert">#MESSAGE#</div>
      <div class="alert alert-danger" role="alert">#MESSAGE#</div>
      <form class="form-horizontal" method="post" action="">
        <div class="form-group">
          <div class="col-sm-12">
            <div class="input-group">
              <span class="input-group-addon">
                <span class="glyphicon glyphicon-user" aria-hidden="true"></span>
              </span>
              <input name="username" type="text" class="form-control" required autofocus>
            </div>
          </div>
        </div>
        <div class="form-group">
          <div class="col-sm-12">
            <div class="input-group">
              <span class="input-group-addon">
                <span class="glyphicon glyphicon-lock" aria-hidden="true"></span>
              </span>
              <input name="password" type="password" class="form-control" required>
            </div>
          </div>
        </div>
        <div class="form-group">
          <div class="col-sm-12">
            <button type="submit" class="btn btn-primary btn-block">Login</button>
          </div>
        </div>
      </form>
    </div><!-- /.container -->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
  </body>', '</html>', '<div class="alert alert-danger" role="alert">#MESSAGE#</div>', '<div class="alert alert-success" role="alert">#MESSAGE#</div>');
INSERT INTO pgapex.page_template (template_id, page_type_id, header, body, footer, error_message, success_message) VALUES (2, 'NORMAL', '<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#TITLE#</title>

    <!-- Bootstrap core CSS -->
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>', '  <body>
    <nav class="navbar navbar-inverse">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">#APPLICATION_NAME#</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
        #POSITION_1#
        </div><!--/.nav-collapse -->
      </div>
    </nav>


    <div class="container">
      #SUCCESS_MESSAGE#
      #ERROR_MESSAGE#
      #BODY#
    </div><!-- /.container -->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
  </body>', '</html>', '<div class="alert alert-danger" role="alert">#MESSAGE#</div>', '<div class="alert alert-success" role="alert">#MESSAGE#</div>');

INSERT INTO pgapex.region_template (template_id, template) VALUES (4, '<div class="panel panel-default">
  <div class="panel-heading">#NAME#</div>
  <div class="panel-body">#BODY#</div>
</div>');

INSERT INTO pgapex.region_template (template_id, template) VALUES (5, '#BODY#');


INSERT INTO pgapex.page_template_display_point (page_template_display_point_id, page_template_id, display_point_id, description) VALUES (1, 2, 'BODY', 'Body');
INSERT INTO pgapex.page_template_display_point (page_template_display_point_id, page_template_id, display_point_id, description) VALUES (2, 2, 'POSITION_1', 'Navigation');