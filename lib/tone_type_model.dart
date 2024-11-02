class ToneTypeModel {
  ExtensionAttributes? extensionAttributes;
  bool? isWysiwygEnabled;
  bool? isHtmlAllowedOnFront;
  bool? usedForSortBy;
  bool? isFilterable;
  bool? isFilterableInSearch;
  bool? isUsedInGrid;
  bool? isVisibleInGrid;
  bool? isFilterableInGrid;
  int? position;
  List<String>? applyTo;
  String? isSearchable;
  String? isVisibleInAdvancedSearch;
  String? isComparable;
  String? isUsedForPromoRules;
  String? isVisibleOnFront;
  String? usedInProductListing;
  bool? isVisible;
  String? scope;
  int? attributeId;
  String? attributeCode;
  String? frontendInput;
  String? entityTypeId;
  bool? isRequired;
  List<Options>? options;
  bool? isUserDefined;
  String? defaultFrontendLabel;
  List<FrontendLabels>? frontendLabels;
  String? backendType;
  String? backendModel;
  String? defaultValue;
  String? isUnique;
  List<String>? validationRules;

  ToneTypeModel(
      {this.extensionAttributes,
      this.isWysiwygEnabled,
      this.isHtmlAllowedOnFront,
      this.usedForSortBy,
      this.isFilterable,
      this.isFilterableInSearch,
      this.isUsedInGrid,
      this.isVisibleInGrid,
      this.isFilterableInGrid,
      this.position,
      this.applyTo,
      this.isSearchable,
      this.isVisibleInAdvancedSearch,
      this.isComparable,
      this.isUsedForPromoRules,
      this.isVisibleOnFront,
      this.usedInProductListing,
      this.isVisible,
      this.scope,
      this.attributeId,
      this.attributeCode,
      this.frontendInput,
      this.entityTypeId,
      this.isRequired,
      this.options,
      this.isUserDefined,
      this.defaultFrontendLabel,
      this.frontendLabels,
      this.backendType,
      this.backendModel,
      this.defaultValue,
      this.isUnique,
      this.validationRules});

  ToneTypeModel.fromJson(Map<String, dynamic> json) {
    extensionAttributes = json['extension_attributes'] != null
        ? new ExtensionAttributes.fromJson(json['extension_attributes'])
        : null;
    isWysiwygEnabled = json['is_wysiwyg_enabled'];
    isHtmlAllowedOnFront = json['is_html_allowed_on_front'];
    usedForSortBy = json['used_for_sort_by'];
    isFilterable = json['is_filterable'];
    isFilterableInSearch = json['is_filterable_in_search'];
    isUsedInGrid = json['is_used_in_grid'];
    isVisibleInGrid = json['is_visible_in_grid'];
    isFilterableInGrid = json['is_filterable_in_grid'];
    position = json['position'];
    isSearchable = json['is_searchable'];
    isVisibleInAdvancedSearch = json['is_visible_in_advanced_search'];
    isComparable = json['is_comparable'];
    isUsedForPromoRules = json['is_used_for_promo_rules'];
    isVisibleOnFront = json['is_visible_on_front'];
    usedInProductListing = json['used_in_product_listing'];
    isVisible = json['is_visible'];
    scope = json['scope'];
    attributeId = json['attribute_id'];
    attributeCode = json['attribute_code'];
    frontendInput = json['frontend_input'];
    entityTypeId = json['entity_type_id'];
    isRequired = json['is_required'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(new Options.fromJson(v));
      });
    }
    isUserDefined = json['is_user_defined'];
    defaultFrontendLabel = json['default_frontend_label'];
    if (json['frontend_labels'] != null) {
      frontendLabels = <FrontendLabels>[];
      json['frontend_labels'].forEach((v) {
        frontendLabels!.add(new FrontendLabels.fromJson(v));
      });
    }
    backendType = json['backend_type'];
    backendModel = json['backend_model'];
    defaultValue = json['default_value'];
    isUnique = json['is_unique'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.extensionAttributes != null) {
      data['extension_attributes'] = this.extensionAttributes!.toJson();
    }
    data['is_wysiwyg_enabled'] = this.isWysiwygEnabled;
    data['is_html_allowed_on_front'] = this.isHtmlAllowedOnFront;
    data['used_for_sort_by'] = this.usedForSortBy;
    data['is_filterable'] = this.isFilterable;
    data['is_filterable_in_search'] = this.isFilterableInSearch;
    data['is_used_in_grid'] = this.isUsedInGrid;
    data['is_visible_in_grid'] = this.isVisibleInGrid;
    data['is_filterable_in_grid'] = this.isFilterableInGrid;
    data['position'] = this.position;
    data['is_searchable'] = this.isSearchable;
    data['is_visible_in_advanced_search'] = this.isVisibleInAdvancedSearch;
    data['is_comparable'] = this.isComparable;
    data['is_used_for_promo_rules'] = this.isUsedForPromoRules;
    data['is_visible_on_front'] = this.isVisibleOnFront;
    data['used_in_product_listing'] = this.usedInProductListing;
    data['is_visible'] = this.isVisible;
    data['scope'] = this.scope;
    data['attribute_id'] = this.attributeId;
    data['attribute_code'] = this.attributeCode;
    data['frontend_input'] = this.frontendInput;
    data['entity_type_id'] = this.entityTypeId;
    data['is_required'] = this.isRequired;
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    data['is_user_defined'] = this.isUserDefined;
    data['default_frontend_label'] = this.defaultFrontendLabel;
    if (this.frontendLabels != null) {
      data['frontend_labels'] =
          this.frontendLabels!.map((v) => v.toJson()).toList();
    }
    data['backend_type'] = this.backendType;
    data['backend_model'] = this.backendModel;
    data['default_value'] = this.defaultValue;
    data['is_unique'] = this.isUnique;
    return data;
  }
}

class ExtensionAttributes {
  bool? isPagebuilderEnabled;

  ExtensionAttributes({this.isPagebuilderEnabled});

  ExtensionAttributes.fromJson(Map<String, dynamic> json) {
    isPagebuilderEnabled = json['is_pagebuilder_enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_pagebuilder_enabled'] = this.isPagebuilderEnabled;
    return data;
  }
}

class Options {
  String? label;
  String? value;

  Options({this.label, this.value});

  Options.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    return data;
  }
}

class FrontendLabels {
  int? storeId;
  String? label;

  FrontendLabels({this.storeId, this.label});

  FrontendLabels.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_id'] = this.storeId;
    data['label'] = this.label;
    return data;
  }
}
