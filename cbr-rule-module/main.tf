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
        for_each = var.rule_contexts[0].attributes == null ? [] : var.rule_contexts[0].attributes
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
        for_each = var.resources[0].attributes == null ? [] : var.resources[0].attributes
        iterator = attribute
        content {
          name     = attribute.value.name
          value    = attribute.value.value
          operator = attribute.value.operator
        }
      }
      dynamic "tags" {
        for_each = var.resources[0].tags == null ? [] : var.resources[0].tags
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
        for_each = var.operations[0].api_types == null ? null : var.operations[0].api_types
        iterator = apitype
        content {
          api_type_id = apitype.value["api_type_id"]
        }
      }
    }
  }
}
