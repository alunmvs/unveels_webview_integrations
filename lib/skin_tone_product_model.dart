class SkinToneProductModel {
  List<Item>? items;
  SearchCriteria? searchCriteria;
  int? totalCount;

  SkinToneProductModel({
    this.items,
    this.searchCriteria,
    this.totalCount,
  });

  factory SkinToneProductModel.fromJson(Map<String, dynamic> json) {
    return SkinToneProductModel(
      items: List<Item>.from(json['items'].map((x) => Item.fromJson(x))),
      searchCriteria: SearchCriteria.fromJson(json['search_criteria']),
      totalCount: json['total_count'],
    );
  }
}

class Item {
  int id;
  String sku;
  String name;
  int attributeSetId;
  double price;
  int status;
  int visibility;
  String typeId;
  String createdAt;
  String updatedAt;
  double weight;
  ExtensionAttributes extensionAttributes;
  List<ProductLink> productLinks;
  List<Option> options;
  List<MediaGalleryEntry> mediaGalleryEntries;
  List<TierPrice> tierPrices;
  List<CustomAttribute> customAttributes;

  Item({
    required this.id,
    required this.sku,
    required this.name,
    required this.attributeSetId,
    required this.price,
    required this.status,
    required this.visibility,
    required this.typeId,
    required this.createdAt,
    required this.updatedAt,
    required this.weight,
    required this.extensionAttributes,
    required this.productLinks,
    required this.options,
    required this.mediaGalleryEntries,
    required this.tierPrices,
    required this.customAttributes,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      sku: json['sku'],
      name: json['name'],
      attributeSetId: json['attribute_set_id'],
      price: json['price'].toDouble(),
      status: json['status'],
      visibility: json['visibility'],
      typeId: json['type_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      weight: json['weight'].toDouble(),
      extensionAttributes:
          ExtensionAttributes.fromJson(json['extension_attributes']),
      productLinks: List<ProductLink>.from(
          json['product_links'].map((x) => ProductLink.fromJson(x))),
      options:
          List<Option>.from(json['options'].map((x) => Option.fromJson(x))),
      mediaGalleryEntries: List<MediaGalleryEntry>.from(
          json['media_gallery_entries']
              .map((x) => MediaGalleryEntry.fromJson(x))),
      tierPrices: List<TierPrice>.from(
          json['tier_prices'].map((x) => TierPrice.fromJson(x))),
      customAttributes: List<CustomAttribute>.from(
          json['custom_attributes'].map((x) => CustomAttribute.fromJson(x))),
    );
  }
}

class ExtensionAttributes {
  List<int> websiteIds;
  List<CategoryLink> categoryLinks;

  ExtensionAttributes({
    required this.websiteIds,
    required this.categoryLinks,
  });

  factory ExtensionAttributes.fromJson(Map<String, dynamic> json) {
    return ExtensionAttributes(
      websiteIds: List<int>.from(json['website_ids']),
      categoryLinks: List<CategoryLink>.from(
          json['category_links'].map((x) => CategoryLink.fromJson(x))),
    );
  }
}

class CategoryLink {
  int position;
  String categoryId;

  CategoryLink({
    required this.position,
    required this.categoryId,
  });

  factory CategoryLink.fromJson(Map<String, dynamic> json) {
    return CategoryLink(
      position: json['position'],
      categoryId: json['category_id'],
    );
  }
}

class MediaGalleryEntry {
  int id;
  String mediaType;
  String label;
  int position;
  bool disabled;
  List<String> types;
  String file;

  MediaGalleryEntry({
    required this.id,
    required this.mediaType,
    required this.label,
    required this.position,
    required this.disabled,
    required this.types,
    required this.file,
  });

  factory MediaGalleryEntry.fromJson(Map<String, dynamic> json) {
    return MediaGalleryEntry(
      id: json['id'],
      mediaType: json['media_type'],
      label: json['label'],
      position: json['position'],
      disabled: json['disabled'],
      types: List<String>.from(json['types']),
      file: json['file'],
    );
  }
}

class CustomAttribute {
  String attributeCode;
  dynamic value;

  CustomAttribute({
    required this.attributeCode,
    required this.value,
  });

  factory CustomAttribute.fromJson(Map<String, dynamic> json) {
    return CustomAttribute(
      attributeCode: json['attribute_code'],
      value: json['value'],
    );
  }
}

class SearchCriteria {
  List<FilterGroup> filterGroups;

  SearchCriteria({
    required this.filterGroups,
  });

  factory SearchCriteria.fromJson(Map<String, dynamic> json) {
    return SearchCriteria(
      filterGroups: List<FilterGroup>.from(
          json['filter_groups'].map((x) => FilterGroup.fromJson(x))),
    );
  }
}

class FilterGroup {
  List<Filter> filters;

  FilterGroup({
    required this.filters,
  });

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      filters:
          List<Filter>.from(json['filters'].map((x) => Filter.fromJson(x))),
    );
  }
}

class Filter {
  String field;
  String value;
  String conditionType;

  Filter({
    required this.field,
    required this.value,
    required this.conditionType,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      field: json['field'],
      value: json['value'],
      conditionType: json['condition_type'],
    );
  }
}

class ProductLink {
  // Define properties as needed
  ProductLink();

  factory ProductLink.fromJson(Map<String, dynamic> json) {
    return ProductLink();
  }
}

class Option {
  // Define properties as needed
  Option();

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option();
  }
}

class TierPrice {
  // Define properties as needed
  TierPrice();

  factory TierPrice.fromJson(Map<String, dynamic> json) {
    return TierPrice();
  }
}
