<?php

namespace App\Models;

use App\Http\Request;
use PDO;

class Page extends Model {
  public function getPages($applicationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_page_get_pages(:applicationId)');
    $statement->bindValue(':applicationId', $applicationId);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function savePage(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_page_save_page(:pageId, :applicationId, :templateId, :title, :alias, :isHomepage, :isAuthRequired)');
    $statement->bindValue(':pageId',         $request->getApiAttribute('pageId'),                   PDO::PARAM_INT);
    $statement->bindValue(':applicationId',  $request->getApiAttribute('applicationId'),            PDO::PARAM_INT);
    $statement->bindValue(':templateId',     $request->getApiAttribute('template'),                 PDO::PARAM_INT);
    $statement->bindValue(':title',          $request->getApiAttribute('title'),                    PDO::PARAM_STR);
    $statement->bindValue(':alias',          $request->getApiAttribute('alias'),                    PDO::PARAM_STR);
    $statement->bindValue(':isHomepage',     $request->getApiAttribute('isHomepage'),               PDO::PARAM_BOOL);
    $statement->bindValue(':isAuthRequired', $request->getApiAttribute('isAuthenticationRequired'), PDO::PARAM_BOOL);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getPage($pageId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_page_get_page(:pageId)');
    $statement->bindValue(':pageId', $pageId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deletePage($pageId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_page_delete_page(:pageId)');
    $statement->bindValue(':pageId', $pageId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}