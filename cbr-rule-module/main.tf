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
    iterator = context
    content {
      dynamic "attributes" {
        for_each = lookup(context.value, "attributes", [])
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
    iterator = resource
    content {
      dynamic "attributes" {
        for_each = lookup(resource.value, "attributes", [])
        iterator = attribute
        content {
          name     = attribute.value.name
          value    = attribute.value.value
          operator = attribute.value.operator
        }
      }
      dynamic "tags" {
        for_each = lookup(resource.value, "tags", [])
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
    iterator = operation
    content {
      dynamic "api_types" {
        for_each = lookup(operation.value, "api_types", [])
        iterator = apitype
        content {
          api_type_id = apitype.value["api_type_id"]
        }
      }
    }
  }
}
