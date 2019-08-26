<?php

namespace App\Models;

use App\Http\Request;
use Exception;
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

  public function saveNavigationRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_save_navigation_region(:regionId, :pageId, :templateId, :tplDpId, :name, :sequence, :isVisible, '
                                    . ':navigationType, :navigation, :navigationTemplate, :repeatLastLevel)');
    $statement->bindValue(':regionId',           $request->getApiAttribute('regionId'),                   PDO::PARAM_INT);
    $statement->bindValue(':pageId',             $request->getApiAttribute('pageId'),                     PDO::PARAM_INT);
    $statement->bindValue(':templateId',         $request->getApiAttribute('regionTemplate'),             PDO::PARAM_INT);
    $statement->bindValue(':tplDpId',            $request->getApiAttribute('pageTemplateDisplayPointId'), PDO::PARAM_INT);
    $statement->bindValue(':name',               $request->getApiAttribute('name'),                       PDO::PARAM_STR);
    $statement->bindValue(':sequence',           $request->getApiAttribute('sequence'),                   PDO::PARAM_INT);
    $statement->bindValue(':isVisible',          $request->getApiAttribute('isVisible'),                  PDO::PARAM_BOOL);

    $statement->bindValue(':navigationType',     $request->getApiAttribute('navigationType'),             PDO::PARAM_STR);
    $statement->bindValue(':navigation',         $request->getApiAttribute('navigation'),                 PDO::PARAM_INT);
    $statement->bindValue(':navigationTemplate', $request->getApiAttribute('navigationTemplate'),         PDO::PARAM_INT);
    $statement->bindValue(':repeatLastLevel',    $request->getApiAttribute('repeatLastLevel'),            PDO::PARAM_BOOL);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function saveReportRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $connection->beginTransaction();
    try {
      if (count($request->getApiAttribute('reportColumns')) === 0) {
        throw new Exception('At least one report column is mandatory');
      }

      $statement = $connection->prepare('SELECT pgapex.f_region_save_report_region(:regionId, :pageId, :templateId, :tplDpId, :name, :sequence, :isVisible, '
        . ':reportTemplate, :viewSchema, :viewName, :itemsPerPage, :showHeader, null, null, :paginationQueryParameter)');
      $statement->bindValue(':regionId',                 $request->getApiAttribute('regionId'),                   PDO::PARAM_INT);
      $statement->bindValue(':pageId',                   $request->getApiAttribute('pageId'),                     PDO::PARAM_INT);
      $statement->bindValue(':templateId',               $request->getApiAttribute('regionTemplate'),             PDO::PARAM_INT);
      $statement->bindValue(':tplDpId',                  $request->getApiAttribute('pageTemplateDisplayPointId'), PDO::PARAM_INT);
      $statement->bindValue(':name',                     $request->getApiAttribute('name'),                       PDO::PARAM_STR);
      $statement->bindValue(':sequence',                 $request->getApiAttribute('sequence'),                   PDO::PARAM_INT);
      $statement->bindValue(':isVisible',                $request->getApiAttribute('isVisible'),                  PDO::PARAM_BOOL);

      $statement->bindValue(':reportTemplate',           $request->getApiAttribute('reportTemplate'),             PDO::PARAM_INT);
      $statement->bindValue(':viewSchema',               $request->getApiAttribute('viewSchema'),                 PDO::PARAM_STR);
      $statement->bindValue(':viewName',                 $request->getApiAttribute('viewName'),                   PDO::PARAM_STR);
      $statement->bindValue(':itemsPerPage',             $request->getApiAttribute('itemsPerPage'),               PDO::PARAM_INT);
      $statement->bindValue(':showHeader',               $request->getApiAttribute('showHeader'),                 PDO::PARAM_BOOL);
      $statement->bindValue(':paginationQueryParameter', $request->getApiAttribute('paginationQueryParameter'),   PDO::PARAM_STR);
      $statement->execute();
      $regionId = $statement->fetchColumn();

      $statement = $connection->prepare('SELECT pgapex.f_region_delete_report_region_columns(:regionId)');
      $statement->bindValue(':regionId', $regionId, PDO::PARAM_INT);
      $statement->execute();

      $columnStatement = $connection->prepare('SELECT pgapex.f_region_create_report_region_column(:regionId, :viewColumnName, :heading, :sequence, :isTextEscaped)');
      $linkStatement = $connection->prepare('SELECT pgapex.f_region_create_report_region_link(:regionId, :heading, :sequence, :isTextEscaped, :url, :linkText, :attributes)');
      foreach ($request->getApiAttribute('reportColumns') as $reportColumn) {
        if ($reportColumn['attributes']['type'] === 'COLUMN') {
          $columnStatement->bindValue(':regionId',       $regionId,                                    PDO::PARAM_INT);
          $columnStatement->bindValue(':viewColumnName', $reportColumn['attributes']['column'],        PDO::PARAM_STR);
          $columnStatement->bindValue(':heading',        $reportColumn['attributes']['heading'],       PDO::PARAM_STR);
          $columnStatement->bindValue(':sequence',       $reportColumn['attributes']['sequence'],      PDO::PARAM_INT);
          $columnStatement->bindValue(':isTextEscaped',  $reportColumn['attributes']['isTextEscaped'], PDO::PARAM_BOOL);
          $columnStatement->execute();
        } elseif ($reportColumn['attributes']['type'] === 'LINK') {
          $linkStatement->bindValue(':regionId',       $regionId,                                     PDO::PARAM_INT);
          $linkStatement->bindValue(':heading',        $reportColumn['attributes']['heading'],        PDO::PARAM_STR);
          $linkStatement->bindValue(':sequence',       $reportColumn['attributes']['sequence'],       PDO::PARAM_INT);
          $linkStatement->bindValue(':isTextEscaped',  $reportColumn['attributes']['isTextEscaped'],  PDO::PARAM_BOOL);
          $linkStatement->bindValue(':url',            $reportColumn['attributes']['linkUrl'],        PDO::PARAM_BOOL);
          $linkStatement->bindValue(':linkText',       $reportColumn['attributes']['linkText'],       PDO::PARAM_BOOL);
          $linkStatement->bindValue(':attributes',     $reportColumn['attributes']['linkAttributes'], PDO::PARAM_BOOL);
          $linkStatement->execute();
        } else {
          throw new Exception('Unknown column type: ' . $reportColumn['attributes']['type']);
        }
      }
      $connection->commit();
      return true;
    } catch (Exception $e) {
      $connection->rollBack();
    }
    return false;
  }

  public function saveReportAndDetailViewRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $connection->beginTransaction();

    try {
      if (count($request->getApiAttribute('reportColumns')) === 0) {
        throw new Exception('At least one report column is mandatory');
      }

      if (count($request->getApiAttribute('detailViewColumns')) === 0) {
        throw new Exception('At least one detail view column is mandatory');
      }

      $reportStatement = $connection->prepare('SELECT pgapex.f_region_save_report_region(:regionId, :pageId, :templateId, :tplDpId, :name, :sequence, :isVisible, '
        . 'null, :viewSchema, :viewName, :itemsPerPage, :showHeader, :uniqueId, :linkTemplateId, :paginationQueryParameter)');
      $reportStatement->bindValue(':regionId',                 $request->getApiAttribute('reportRegionId'),                 PDO::PARAM_INT);
      $reportStatement->bindValue(':pageId',                   $request->getApiAttribute('reportPageId'),                   PDO::PARAM_INT);
      $reportStatement->bindValue(':templateId',               $request->getApiAttribute('reportRegionTemplate'),           PDO::PARAM_INT);
      $reportStatement->bindValue(':tplDpId',                  $request->getApiAttribute('pageTemplateDisplayPointId'),     PDO::PARAM_INT);
      $reportStatement->bindValue(':name',                     $request->getApiAttribute('reportName'),                     PDO::PARAM_STR);
      $reportStatement->bindValue(':sequence',                 $request->getApiAttribute('reportSequence'),                 PDO::PARAM_INT);
      $reportStatement->bindValue(':isVisible',                $request->getApiAttribute('reportIsVisible'),                PDO::PARAM_BOOL);
      $reportStatement->bindValue(':viewSchema',               $request->getApiAttribute('viewSchema'),                     PDO::PARAM_STR);
      $reportStatement->bindValue(':viewName',                 $request->getApiAttribute('viewName'),                       PDO::PARAM_STR);
      $reportStatement->bindValue(':itemsPerPage',             $request->getApiAttribute('reportItemsPerPage'),             PDO::PARAM_INT);
      $reportStatement->bindValue(':showHeader',               $request->getApiAttribute('reportShowHeader'),               PDO::PARAM_BOOL);
      $reportStatement->bindValue(':uniqueId',                 $request->getApiAttribute('uniqueId'),                       PDO::PARAM_STR);
      $reportStatement->bindValue(':linkTemplateId',           $request->getApiAttribute('reportTemplate'),                 PDO::PARAM_INT);
      $reportStatement->bindValue(':paginationQueryParameter', $request->getApiAttribute('reportPaginationQueryParameter'), PDO::PARAM_STR);
      $reportStatement->execute();
      $reportRegionId = $reportStatement->fetchColumn();

      $reportStatement = $connection->prepare('SELECT pgapex.f_region_delete_report_region_columns(:regionId)');
      $reportStatement->bindValue(':regionId', $reportRegionId, PDO::PARAM_INT);
      $reportStatement->execute();

      $reportColumnStatement = $connection->prepare('SELECT pgapex.f_region_create_report_region_column(:regionId, :viewColumnName, :heading, :sequence, :isTextEscaped)');
      $reportLinkStatement = $connection->prepare('SELECT pgapex.f_region_create_report_region_link(:regionId, :heading, :sequence, :isTextEscaped, :url, :linkText, :attributes)');
      foreach ($request->getApiAttribute('reportColumns') as $reportColumn) {
        if ($reportColumn['attributes']['type'] === 'COLUMN') {
          $reportColumnStatement->bindValue(':regionId',       $reportRegionId,                              PDO::PARAM_INT);
          $reportColumnStatement->bindValue(':viewColumnName', $reportColumn['attributes']['column'],        PDO::PARAM_STR);
          $reportColumnStatement->bindValue(':heading',        $reportColumn['attributes']['heading'],       PDO::PARAM_STR);
          $reportColumnStatement->bindValue(':sequence',       $reportColumn['attributes']['sequence'],      PDO::PARAM_INT);
          $reportColumnStatement->bindValue(':isTextEscaped',  $reportColumn['attributes']['isTextEscaped'], PDO::PARAM_BOOL);
          $reportColumnStatement->execute();
        } elseif ($reportColumn['attributes']['type'] === 'LINK') {
          $reportLinkStatement->bindValue(':regionId',       $reportRegionId,                               PDO::PARAM_INT);
          $reportLinkStatement->bindValue(':heading',        $reportColumn['attributes']['heading'],        PDO::PARAM_STR);
          $reportLinkStatement->bindValue(':sequence',       $reportColumn['attributes']['sequence'],       PDO::PARAM_INT);
          $reportLinkStatement->bindValue(':isTextEscaped',  $reportColumn['attributes']['isTextEscaped'],  PDO::PARAM_BOOL);
          $reportLinkStatement->bindValue(':url',            $reportColumn['attributes']['linkUrl'],        PDO::PARAM_BOOL);
          $reportLinkStatement->bindValue(':linkText',       $reportColumn['attributes']['linkText'],       PDO::PARAM_BOOL);
          $reportLinkStatement->bindValue(':attributes',     $reportColumn['attributes']['linkAttributes'], PDO::PARAM_BOOL);
          $reportLinkStatement->execute();
        } else {
          throw new Exception('Unknown column type: ' . $reportColumn['attributes']['type']);
        }
      }

      $detailViewStatement = $connection->prepare('SELECT pgapex.f_region_save_detailview_region(:regionId, :pageId, '
      . ':templateId, :tplDpId, :name, :sequence, :isVisible, :reportRegionId, :detailViewTemplateId, :viewSchema, :viewName, :uniqueId)');
      $detailViewStatement->bindValue(':regionId',              $request->getApiAttribute('detailViewRegionId'),          PDO::PARAM_INT);
      $detailViewStatement->bindValue(':pageId',                $request->getApiAttribute('detailViewPageId'),            PDO::PARAM_INT);
      $detailViewStatement->bindValue(':templateId',            $request->getApiAttribute('detailViewRegionTemplate'),    PDO::PARAM_INT);
      $detailViewStatement->bindValue(':tplDpId',               $request->getApiAttribute('pageTemplateDisplayPointId'),  PDO::PARAM_INT);
      $detailViewStatement->bindValue(':name',                  $request->getApiAttribute('detailViewName'),              PDO::PARAM_STR);
      $detailViewStatement->bindValue(':sequence',              $request->getApiAttribute('detailViewSequence'),          PDO::PARAM_INT);
      $detailViewStatement->bindValue(':isVisible',             $request->getApiAttribute('detailViewIsVisible'),         PDO::PARAM_BOOL);
      $detailViewStatement->bindValue(':reportRegionId',        $reportRegionId,                                                   PDO::PARAM_INT);
      $detailViewStatement->bindValue(':detailViewTemplateId',  $request->getApiAttribute('detailViewTemplate'),          PDO::PARAM_INT);
      $detailViewStatement->bindValue(':viewSchema',            $request->getApiAttribute('viewSchema'),                  PDO::PARAM_STR);
      $detailViewStatement->bindValue(':viewName',              $request->getApiAttribute('viewName'),                    PDO::PARAM_STR);
      $detailViewStatement->bindValue(':uniqueId',              $request->getApiAttribute('uniqueId'),                    PDO::PARAM_STR);
      $detailViewStatement->execute();
      $detailViewRegionId = $detailViewStatement->fetchColumn();

      $detailViewStatement = $connection->prepare('SELECT pgapex.f_region_delete_detailview_region_columns(:regionId)');
      $detailViewStatement->bindValue(':regionId', $detailViewRegionId, PDO::PARAM_INT);
      $detailViewStatement->execute();

      $detailViewColumnStatement = $connection->prepare('SELECT pgapex.f_region_create_detailview_region_column(:regionId, :viewColumnName, :heading, :sequence, :isTextEscaped)');
      $detailViewLinkStatement = $connection->prepare('SELECT pgapex.f_region_create_detailview_region_link(:regionId, :heading, :sequence, :isTextEscaped, :url, :linkText, :attributes)');
      foreach ($request->getApiAttribute('detailViewColumns') as $detailViewColumn) {
        if ($detailViewColumn['attributes']['type'] === 'COLUMN') {
          $detailViewColumnStatement->bindValue(':regionId',       $detailViewRegionId,                                PDO::PARAM_INT);
          $detailViewColumnStatement->bindValue(':viewColumnName', $detailViewColumn['attributes']['column'],          PDO::PARAM_STR);
          $detailViewColumnStatement->bindValue(':heading',        $detailViewColumn['attributes']['heading'],         PDO::PARAM_STR);
          $detailViewColumnStatement->bindValue(':sequence',       $detailViewColumn['attributes']['sequence'],        PDO::PARAM_INT);
          $detailViewColumnStatement->bindValue(':isTextEscaped',  $detailViewColumn['attributes']['isTextEscaped'],   PDO::PARAM_BOOL);
          $detailViewColumnStatement->execute();
        } elseif ($detailViewColumn['attributes']['type'] === 'LINK') {
          $detailViewLinkStatement->bindValue(':regionId',       $detailViewRegionId,                               PDO::PARAM_INT);
          $detailViewLinkStatement->bindValue(':heading',        $detailViewColumn['attributes']['heading'],        PDO::PARAM_STR);
          $detailViewLinkStatement->bindValue(':sequence',       $detailViewColumn['attributes']['sequence'],       PDO::PARAM_INT);
          $detailViewLinkStatement->bindValue(':isTextEscaped',  $detailViewColumn['attributes']['isTextEscaped'],  PDO::PARAM_BOOL);
          $detailViewLinkStatement->bindValue(':url',            $detailViewColumn['attributes']['linkUrl'],        PDO::PARAM_BOOL);
          $detailViewLinkStatement->bindValue(':linkText',       $detailViewColumn['attributes']['linkText'],       PDO::PARAM_BOOL);
          $detailViewLinkStatement->bindValue(':attributes',     $detailViewColumn['attributes']['linkAttributes'], PDO::PARAM_BOOL);
          $detailViewLinkStatement->execute();
        } else {
          throw new Exception('Unknown column type: ' . $detailViewColumn['attributes']['type']);
        }
      }

      $subReport = $connection->prepare('SELECT pgapex.f_subregion_delete_subregion(:parentRegionId)');
      $subReport->bindValue(':parentRegionId', $detailViewRegionId, PDO::PARAM_INT);
      $subReport->execute();

      if (count($request->getApiAttribute('subRegions')) > 0) {
        foreach ($request->getApiAttribute('subRegions') as $subRegion) {
          if ($subRegion['type'] === 'SUBREPORT') {
            $subReportStatement = $connection->prepare('SELECT pgapex.f_region_save_report_subregion(:subRegionId, :subRegionTemplateId, :name, :sequence, :isVisible, :queryParameter, :parentRegionId, :reportTemplateId,:viewSchema, :viewName, :itemsPerPage, :showHeader, :uniqueId)');

            $subReportStatement->bindValue(':subRegionId',          $subRegion['attributes']['subRegionId'],               PDO::PARAM_INT);
            $subReportStatement->bindValue(':subRegionTemplateId',  $subRegion['attributes']['subRegionTemplateId'],       PDO::PARAM_INT);
            $subReportStatement->bindValue(':name',                 $subRegion['attributes']['name'],                      PDO::PARAM_STR);
            $subReportStatement->bindValue(':sequence',             $subRegion['attributes']['sequence'],                  PDO::PARAM_INT);
            $subReportStatement->bindValue(':isVisible',            $subRegion['attributes']['isVisible'],                 PDO::PARAM_BOOL);
            $subReportStatement->bindValue(':queryParameter',       $subRegion['attributes']['paginationQueryParameter'],  PDO::PARAM_STR);
            $subReportStatement->bindValue(':parentRegionId',       $detailViewRegionId,                                   PDO::PARAM_INT);
            $subReportStatement->bindValue(':reportTemplateId',     $subRegion['attributes']['reportTemplateId'],          PDO::PARAM_INT);
            $subReportStatement->bindValue(':viewSchema',           $subRegion['attributes']['viewSchema'],                PDO::PARAM_STR);
            $subReportStatement->bindValue(':viewName',             $subRegion['attributes']['viewName'],                  PDO::PARAM_STR);
            $subReportStatement->bindValue(':itemsPerPage',         $subRegion['attributes']['itemsPerPage'],              PDO::PARAM_INT);
            $subReportStatement->bindValue(':showHeader',           $subRegion['attributes']['showHeader'],                PDO::PARAM_BOOL);
            $subReportStatement->bindValue(':uniqueId',             $subRegion['attributes']['linkedColumn'],              PDO::PARAM_STR);
            $subReportStatement->execute();
            $subReportSubRegionId = $subReportStatement->fetchColumn();

            $subReportStatement = $connection->prepare('SELECT pgapex.f_subregion_delete_report_subregion_columns(:subRegionId)');
            $subReportStatement->bindValue(':subRegionId', $subReportSubRegionId, PDO::PARAM_INT);
            $subReportStatement->execute();

            $subReportColumnStatement = $connection->prepare('SELECT pgapex.f_subregion_create_report_subregion_column(:subRegionId, :viewColumnName, :heading, :sequence, :isTextEscaped)');
            $subReportLinkStatement = $connection->prepare('SELECT pgapex.f_subregion_create_report_subregion_link(:subRegionId, :heading, :sequence, :isTextEscaped, :url, :linkText, :attributes)');

            foreach ($subRegion['attributes']['columns'] as $subReportColumn) {
              if ($subReportColumn['attributes']['type'] === 'COLUMN') {
                $subReportColumnStatement->bindValue(':subRegionId',    $subReportSubRegionId,                           PDO::PARAM_INT);
                $subReportColumnStatement->bindValue(':viewColumnName', $subReportColumn['attributes']['column'],        PDO::PARAM_STR);
                $subReportColumnStatement->bindValue(':heading',        $subReportColumn['attributes']['heading'],       PDO::PARAM_STR);
                $subReportColumnStatement->bindValue(':sequence',       $subReportColumn['attributes']['sequence'],      PDO::PARAM_INT);
                $subReportColumnStatement->bindValue(':isTextEscaped',  $subReportColumn['attributes']['isTextEscaped'], PDO::PARAM_BOOL);
                $subReportColumnStatement->execute();
              } elseif ($subReportColumn['attributes']['type'] === 'LINK') {
                $subReportLinkStatement->bindValue(':subRegionId',    $subReportSubRegionId,                            PDO::PARAM_INT);
                $subReportLinkStatement->bindValue(':heading',        $subReportColumn['attributes']['heading'],        PDO::PARAM_STR);
                $subReportLinkStatement->bindValue(':sequence',       $subReportColumn['attributes']['sequence'],       PDO::PARAM_INT);
                $subReportLinkStatement->bindValue(':isTextEscaped',  $subReportColumn['attributes']['isTextEscaped'],  PDO::PARAM_BOOL);
                $subReportLinkStatement->bindValue(':url',            $subReportColumn['attributes']['linkUrl'],        PDO::PARAM_BOOL);
                $subReportLinkStatement->bindValue(':linkText',       $subReportColumn['attributes']['linkText'],       PDO::PARAM_BOOL);
                $subReportLinkStatement->bindValue(':attributes',     $subReportColumn['attributes']['linkAttributes'], PDO::PARAM_BOOL);
                $subReportLinkStatement->execute();
              } else {
                throw new Exception('Unknown column type: ' . $subReportColumn['attributes']['type']);
              }
            }
          }
        }
      }

      $connection->commit();
      return true;
    } catch (Exception $e) {
      $connection->rollBack();
    }

    return false;
  }

  public function saveFormRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $connection->beginTransaction();
    try {
      if ($request->getApiAttribute('regionId') !== null) {
        $statement = $connection->prepare('SELECT pgapex.f_region_delete_form_pre_fill_and_form_field(:regionId)');
        $statement->bindValue(':regionId', $request->getApiAttribute('regionId'), PDO::PARAM_INT);
        $statement->execute();
      }

      $formPreFillId = null;

      if ($request->getApiAttribute('formPreFill') === true && $request->getApiAttribute('preFill') !== null) {
        $formPreFillStatement = $connection->prepare('SELECT pgapex.f_region_save_form_pre_fill(:schemaName, :viewName)');
        $formPreFillStatement->bindValue(':schemaName', $request->getApiAttribute('preFill')['attributes']['schemaName'], PDO::PARAM_STR);
        $formPreFillStatement->bindValue(':viewName',   $request->getApiAttribute('preFill')['attributes']['viewName'],   PDO::PARAM_STR);
        $formPreFillStatement->execute();
        $formPreFillId = $formPreFillStatement->fetchColumn();
      }

      $formRegionStatement = $connection->prepare('SELECT pgapex.f_region_save_form_region(:regionId, :pageId, :templateId, :tplDpId, :name, :sequence, :isVisible, '
        . ':formPreFillId, :formTemplateId, :buttonTemplateId, :schemaName, :functionName, :buttonLabel, :successMessage, :errorMessage, :redirectUrl)');
      $formRegionStatement->bindValue(':regionId',                 $request->getApiAttribute('regionId'),                   PDO::PARAM_INT);
      $formRegionStatement->bindValue(':pageId',                   $request->getApiAttribute('pageId'),                     PDO::PARAM_INT);
      $formRegionStatement->bindValue(':templateId',               $request->getApiAttribute('regionTemplate'),             PDO::PARAM_INT);
      $formRegionStatement->bindValue(':tplDpId',                  $request->getApiAttribute('pageTemplateDisplayPointId'), PDO::PARAM_INT);
      $formRegionStatement->bindValue(':name',                     $request->getApiAttribute('name'),                       PDO::PARAM_STR);
      $formRegionStatement->bindValue(':sequence',                 $request->getApiAttribute('sequence'),                   PDO::PARAM_INT);
      $formRegionStatement->bindValue(':isVisible',                $request->getApiAttribute('isVisible'),                  PDO::PARAM_BOOL);
      $formRegionStatement->bindValue(':formPreFillId',            $formPreFillId,                                          PDO::PARAM_INT);
      $formRegionStatement->bindValue(':formTemplateId',           $request->getApiAttribute('formTemplate'),               PDO::PARAM_INT);
      $formRegionStatement->bindValue(':buttonTemplateId',         $request->getApiAttribute('buttonTemplate'),             PDO::PARAM_INT);
      $formRegionStatement->bindValue(':schemaName',               $request->getApiAttribute('functionSchema'),             PDO::PARAM_STR);
      $formRegionStatement->bindValue(':functionName',             $request->getApiAttribute('functionName'),               PDO::PARAM_STR);
      $formRegionStatement->bindValue(':buttonLabel',              $request->getApiAttribute('buttonLabel'),                PDO::PARAM_STR);
      $formRegionStatement->bindValue(':successMessage',           $request->getApiAttribute('successMessage'),             PDO::PARAM_STR);
      $formRegionStatement->bindValue(':errorMessage',             $request->getApiAttribute('errorMessage'),               PDO::PARAM_STR);
      $formRegionStatement->bindValue(':redirectUrl',              $request->getApiAttribute('redirectUrl'),                PDO::PARAM_STR);
      $formRegionStatement->execute();
      $formRegionId = $formRegionStatement->fetchColumn();

      $listOfValuesStatement = $connection->prepare('SELECT pgapex.f_region_save_list_of_values(:valueColumn, :labelColumn, :viewName, :schemaName)');
      $formFieldStatement = $connection->prepare('SELECT pgapex.f_region_save_form_field(:regionId, :fieldType, :listOfValuesId, :formFieldTemplateId, '
                                               . ':fieldPreFillViewColumnName, :formElementName, :label, :sequence, :isMandatory, :isVisible, :defaultValue, :helpText, '
                                               . ':functionParameterType, :functionParameterOrdinalPosition)');
      foreach ($request->getApiAttribute('formFields') as $formField) {
        $listOfValuesId = null;
        if ($formField['attributes']['listOfValuesView'] !== null) {
          $listOfValuesStatement->bindValue(':valueColumn', $formField['attributes']['listOfValuesValue'],  PDO::PARAM_STR);
          $listOfValuesStatement->bindValue(':labelColumn', $formField['attributes']['listOfValuesLabel'],  PDO::PARAM_STR);
          $listOfValuesStatement->bindValue(':viewName',    $formField['attributes']['listOfValuesView'],   PDO::PARAM_STR);
          $listOfValuesStatement->bindValue(':schemaName',  $formField['attributes']['listOfValuesSchema'], PDO::PARAM_STR);
          $listOfValuesStatement->execute();
          $listOfValuesId = $listOfValuesStatement->fetchColumn();
        }

        $formFieldStatement->bindValue(':regionId',                         $formRegionId,                                                 PDO::PARAM_INT);
        $formFieldStatement->bindValue(':fieldType',                        $formField['attributes']['fieldType'],                         PDO::PARAM_STR);
        $formFieldStatement->bindValue(':listOfValuesId',                   $listOfValuesId,                                               PDO::PARAM_INT);
        $formFieldStatement->bindValue(':formFieldTemplateId',              $formField['attributes']['fieldTemplate'],                     PDO::PARAM_INT);
        $formFieldStatement->bindValue(':fieldPreFillViewColumnName',       $formField['attributes']['preFillColumn'],                     PDO::PARAM_STR);
        $formFieldStatement->bindValue(':formElementName',                  $formField['attributes']['inputName'],                         PDO::PARAM_STR);
        $formFieldStatement->bindValue(':label',                            $formField['attributes']['label'],                             PDO::PARAM_STR);
        $formFieldStatement->bindValue(':sequence',                         $formField['attributes']['sequence'],                          PDO::PARAM_INT);
        $formFieldStatement->bindValue(':isMandatory',                      $formField['attributes']['isMandatory'],                       PDO::PARAM_BOOL);
        $formFieldStatement->bindValue(':isVisible',                        $formField['attributes']['isVisible'],                         PDO::PARAM_BOOL);
        $formFieldStatement->bindValue(':defaultValue',                     $formField['attributes']['defaultValue'],                      PDO::PARAM_STR);
        $formFieldStatement->bindValue(':helpText',                         $formField['attributes']['helpText'],                          PDO::PARAM_STR);
        $formFieldStatement->bindValue(':functionParameterType',            $formField['attributes']['functionParameterType'],             PDO::PARAM_STR);
        $formFieldStatement->bindValue(':functionParameterOrdinalPosition', $formField['attributes']['functionParameterOrdinalPosition'],  PDO::PARAM_STR);
        $formFieldStatement->execute();
      }

      if ($request->getApiAttribute('formPreFill') === true && $request->getApiAttribute('preFill') !== null) {
        $fetchRowConditionStatement = $connection->prepare('SELECT pgapex.f_region_save_fetch_row_condition(:formPreFillId, :regionId, :urlParameter, :columnName)');
        foreach ($request->getApiAttribute('preFill')['attributes']['conditions'] as $condition) {
          if ($condition['value'] !== null) {
            $fetchRowConditionStatement->bindValue(':formPreFillId', $formPreFillId,           PDO::PARAM_INT);
            $fetchRowConditionStatement->bindValue(':regionId',      $formRegionId,            PDO::PARAM_INT);
            $fetchRowConditionStatement->bindValue(':urlParameter',  $condition['value'],      PDO::PARAM_STR);
            $fetchRowConditionStatement->bindValue(':columnName',    $condition['columnName'], PDO::PARAM_STR);
            $fetchRowConditionStatement->execute();
          }
        }
      }

      $connection->commit();
      return true;
    } catch (Exception $e) {
      $connection->rollBack();
    }
    return false;
  }

  public function saveTabularFormRegion(Request $request) {
    $connection = $this->getDb()->getConnection();
    $connection->beginTransaction();

    try {
      if (count($request->getApiAttribute('tabularFormColumns')) === 0) {
        throw new Exception('At least one report column is mandatory');
      }

      if (count($request->getApiAttribute('tabularFormButtons')) === 0) {
        throw new Exception('At least one button is mandatory');
      }

      $statement = $connection->prepare('SELECT pgapex.f_region_save_tabularform_region(:regionId, :pageId, '
      . ':regionTemplateId, :tplDpId, :name, :sequence, :isVisible, :tabularFormTemplateId, :viewSchema, :viewName, '
      . ':itemsPerPage, :showHeader, :uniqueId, :paginationQueryParameter)');
      $statement->bindValue(':regionId',                 $request->getApiAttribute('regionId'),                   PDO::PARAM_INT);
      $statement->bindValue(':pageId',                   $request->getApiAttribute('pageId'),                     PDO::PARAM_INT);
      $statement->bindValue(':regionTemplateId',         $request->getApiAttribute('regionTemplate'),             PDO::PARAM_INT);
      $statement->bindValue(':tplDpId',                  $request->getApiAttribute('pageTemplateDisplayPointId'), PDO::PARAM_INT);
      $statement->bindValue(':name',                     $request->getApiAttribute('name'),                       PDO::PARAM_STR);
      $statement->bindValue(':sequence',                 $request->getApiAttribute('sequence'),                   PDO::PARAM_INT);
      $statement->bindValue(':isVisible',                $request->getApiAttribute('isVisible'),                  PDO::PARAM_BOOL);
      $statement->bindValue(':tabularFormTemplateId',    $request->getApiAttribute('tabularFormTemplate'),        PDO::PARAM_INT);
      $statement->bindValue(':viewSchema',               $request->getApiAttribute('viewSchema'),                 PDO::PARAM_STR);
      $statement->bindValue(':viewName',                 $request->getApiAttribute('viewName'),                   PDO::PARAM_STR);
      $statement->bindValue(':itemsPerPage',             $request->getApiAttribute('itemsPerPage'),               PDO::PARAM_INT);
      $statement->bindValue(':showHeader',               $request->getApiAttribute('showHeader'),                 PDO::PARAM_BOOL);
      $statement->bindValue(':uniqueId',                 $request->getApiAttribute('uniqueId'),                   PDO::PARAM_STR);
      $statement->bindValue(':paginationQueryParameter', $request->getApiAttribute('paginationQueryParameter'),   PDO::PARAM_STR);
      $statement->execute();
      $regionId = $statement->fetchColumn();

      $statement = $connection->prepare('SELECT pgapex.f_region_delete_tabularform_region_columns(:regionId)');
      $statement->bindValue(':regionId', $regionId, PDO::PARAM_INT);
      $statement->execute();

      $columnStatement = $connection->prepare('SELECT pgapex.f_region_create_tabularform_region_column(:regionId, :viewColumnName, '
        . ':heading, :sequence, :isTextEscaped)');
      $linkStatement = $connection->prepare('SELECT pgapex.f_region_create_tabularform_region_link(:regionId, :heading,'
        . ':sequence, :isTextEscaped, :url, :linkText, :attributes)');
      foreach ($request->getApiAttribute('tabularFormColumns') as $tabularFormColumn) {
        if ($tabularFormColumn['attributes']['type'] === 'COLUMN') {
          $columnStatement->bindValue(':regionId',       $regionId,                                         PDO::PARAM_INT);
          $columnStatement->bindValue(':viewColumnName', $tabularFormColumn['attributes']['column'],        PDO::PARAM_STR);
          $columnStatement->bindValue(':heading',        $tabularFormColumn['attributes']['heading'],       PDO::PARAM_STR);
          $columnStatement->bindValue(':sequence',       $tabularFormColumn['attributes']['sequence'],      PDO::PARAM_INT);
          $columnStatement->bindValue(':isTextEscaped',  $tabularFormColumn['attributes']['isTextEscaped'], PDO::PARAM_BOOL);
          $columnStatement->execute();
        } elseif ($tabularFormColumn['attributes']['type'] === 'LINK') {
          $linkStatement->bindValue(':regionId',       $regionId,                                          PDO::PARAM_INT);
          $linkStatement->bindValue(':heading',        $tabularFormColumn['attributes']['heading'],        PDO::PARAM_STR);
          $linkStatement->bindValue(':sequence',       $tabularFormColumn['attributes']['sequence'],       PDO::PARAM_INT);
          $linkStatement->bindValue(':isTextEscaped',  $tabularFormColumn['attributes']['isTextEscaped'],  PDO::PARAM_BOOL);
          $linkStatement->bindValue(':url',            $tabularFormColumn['attributes']['linkUrl'],        PDO::PARAM_BOOL);
          $linkStatement->bindValue(':linkText',       $tabularFormColumn['attributes']['linkText'],       PDO::PARAM_BOOL);
          $linkStatement->bindValue(':attributes',     $tabularFormColumn['attributes']['linkAttributes'], PDO::PARAM_BOOL);
          $linkStatement->execute();
        } else {
          throw new Exception('Unknown column type: ' . $tabularFormColumn['attributes']['type']);
        }
      }

      $statement = $connection->prepare('SELECT pgapex.f_region_delete_tabularform_region_functions(:regionId)');
      $statement->bindValue(':regionId', $regionId, PDO::PARAM_INT);
      $statement->execute();

      $buttonStatement = $connection->prepare('SELECT pgapex.f_region_create_tabularform_region_function(:regionId, '
        . ':buttonTemplateId, :functionSchema, :functionName, :buttonLabel, :sequence, :successMessage, :errorMessage, :appUserParameter)');
      foreach ($request->getApiAttribute('tabularFormButtons') as $tabularFormButton) {
        $buttonStatement->bindValue(':regionId',          $regionId,                              PDO::PARAM_INT);
        $buttonStatement->bindValue(':buttonTemplateId',  $tabularFormButton['templateId'],       PDO::PARAM_INT);
        $buttonStatement->bindValue(':functionSchema',    $tabularFormButton['functionSchema'],   PDO::PARAM_STR);
        $buttonStatement->bindValue(':functionName',      $tabularFormButton['functionName'],     PDO::PARAM_STR);
        $buttonStatement->bindValue(':buttonLabel',       $tabularFormButton['label'],            PDO::PARAM_STR);
        $buttonStatement->bindValue(':sequence',          $tabularFormButton['sequence'],         PDO::PARAM_INT);
        $buttonStatement->bindValue(':successMessage',    $tabularFormButton['successMessage'],   PDO::PARAM_STR);
        $buttonStatement->bindValue(':errorMessage',      $tabularFormButton['errorMessage'],     PDO::PARAM_STR);
        $buttonStatement->bindValue(':appUserParameter',  $tabularFormButton['appUserParameter'], PDO::PARAM_BOOL);
        $buttonStatement->execute();
      }

      $connection->commit();
      return true;
    } catch (Exception $e) {
      $connection->rollBack();
    }
    return false;
  }
}