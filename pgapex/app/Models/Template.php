<?php

namespace App\Models;

class Template extends Model {
  public function getLoginTemplates() {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_template_get_login_templates()');
    $statement->execute();
    return $statement->fetchColumn();
  }
}