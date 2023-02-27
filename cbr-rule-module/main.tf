##############################################################################
# Context Based Restrictions module
#
# Creates CBR Rule
##############################################################################

resource "ibm_cbr_rule" "cbr_rule" {
  description      = var.rule_description
  enforcement_mode = var.enforcement_mode

  dynamic "contexts" {
    for_each = var.rule_contexts
    content {
      dynamic "attributes" {
        for_each = contexts.value.attributes == null ? [] : contexts.value.attributes
        iterator = attribute
        content {
          name  = attribute.value.name
          value = attribute.value.value
        }
      }
    }
  }

  dynamic "resources" {
    for_each = var.resources
    content {
      dynamic "attributes" {
        for_each = resources.value.attributes == null ? [] : resources.value.attributes
        iterator = attribute
        content {
          name     = attribute.value.name
          value    = attribute.value.value
          operator = attribute.value.operator
        }
      }
      dynamic "tags" {
        for_each = resources.value.tags == null ? [] : resources.value.tags
        iterator = tag
        content {
          name  = tag.value.name
          value = tag.value.value
        }
      }
    }
  }

  dynamic "operations" {
    for_each = var.operations
    content {
      dynamic "api_types" {
        for_each = operations.value.api_types == null ? null : operations.value.api_types
        iterator = apitype
        content {
          api_type_id = apitype.value["api_type_id"]
        }
      }
    }
  }
}
