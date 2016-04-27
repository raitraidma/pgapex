<?php

namespace App\Models;

use App\Http\Request;
use PDO;

class Region extends Model {
  public function getDisplayPointsWithRegions($pageId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_get_display_points_with_regions(:pageId)');
    $statement->bindValue(':pageId', $pageId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function getRegion($regionId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_get_region(:regionId)');
    $statement->bindValue(':regionId', $regionId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deleteRegion($regionId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_delete_region(:regionId)');
    $statement->bindValue(':regionId', $regionId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function saveHtmlRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_save_html_region(:regionId, :pageId, :templateId, :tplDpId, :name, :sequence, :isVisible, :content)');
    $statement->bindValue(':regionId',   $request->getApiAttribute('regionId'),                   PDO::PARAM_INT);
    $statement->bindValue(':pageId',     $request->getApiAttribute('pageId'),                     PDO::PARAM_INT);
    $statement->bindValue(':templateId', $request->getApiAttribute('regionTemplate'),             PDO::PARAM_INT);
    $statement->bindValue(':tplDpId',    $request->getApiAttribute('pageTemplateDisplayPointId'), PDO::PARAM_INT);
    $statement->bindValue(':name',       $request->getApiAttribute('name'),                       PDO::PARAM_STR);
    $statement->bindValue(':sequence',   $request->getApiAttribute('sequence'),                   PDO::PARAM_INT);
    $statement->bindValue(':isVisible',  $request->getApiAttribute('isVisible'),                  PDO::PARAM_BOOL);
    $statement->bindValue(':content',    $request->getApiAttribute('content'),                    PDO::PARAM_STR);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}