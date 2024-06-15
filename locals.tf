locals {
  env          = terraform.workspace
  project_name = "financify"
  prefix       = "${local.project_name}-${local.env}"

  api_name        = "${local.prefix}"
  authorizer_name = "${local.prefix}"

  domain_name     = "${local.project_name}.cyrilmarchive.com"
  route53_zone_id = "Z2PY3FU1QKYN1V"


  api_resources = {
    users = {
      path   = "users"
      parent = null
    },
    users_id = {
      path   = "{userId}"
      parent = "users"
    }
    incomes = {
      path   = "incomes"
      parent = null
    },
    expenses = {
      path   = "expenses"
      parent = null
    }
    categories = {
      path   = "categories"
      parent = "expenses"
    }
  }

  api_methods = {
    "list_users" = {
      resource      = "users"
      is_root       = true
      is_authorized = true
      http_method   = "GET"
      lambda        = "${local.lambda_function_name_list_users}"
    },
    "get_user" = {
      resource      = "users_id"
      is_root       = false
      is_authorized = true
      http_method   = "GET"
      lambda        = "${local.lambda_function_name_get_user}"
    },
    "delete_user" = {
      resource      = "users_id"
      is_root       = false
      is_authorized = true
      http_method   = "DELETE"
      lambda        = "${local.lambda_function_name_delete_user}"
    },
    "update_user" = {
      resource      = "users_id"
      is_root       = false
      is_authorized = true
      http_method   = "PUT"
      lambda        = "${local.lambda_function_name_update_user}"
    }
    "add_user" = {
      resource      = "users"
      is_root       = true
      is_authorized = true
      http_method   = "POST"
      lambda        = "${local.lambda_function_name_add_user}"
    }
  }

  dynamodb_table_name_user               = "${local.prefix}-user"
  dynamodb_table_name_income             = "${local.prefix}-income"
  dynamodb_table_name_expenses           = "${local.prefix}-expenses"
  dynamodb_table_name_expense_categories = "${local.prefix}-expense-categories"
  table_names                            = [
    local.dynamodb_table_name_user,
    local.dynamodb_table_name_income,
    local.dynamodb_table_name_expenses,
    local.dynamodb_table_name_expense_categories
  ]

  lambda_function_name_add_user    = "${local.prefix}-add-user"
  lambda_function_name_list_users  = "${local.prefix}-list-users"
  lambda_function_name_get_user    = "${local.prefix}-get-user"
  lambda_function_name_delete_user = "${local.prefix}-delete-user"
  lambda_function_name_update_user = "${local.prefix}-update-user"

  role_name_add_user    = "${local.prefix}-add-user"
  role_name_list_users  = "${local.prefix}-list-users"
  role_name_get_user    = "${local.prefix}-get-user"
  role_name_delete_user = "${local.prefix}-delete-user"
  role_name_update_user = "${local.prefix}-update-user"

  policy_update_item         = "${local.prefix}-update-item"
  policy_update_item_actions = [
    "dynamodb:UpdateItem",
    "dynamodb:PutItem"
  ]
  policy_list_items         = "${local.prefix}-list-items"
  policy_list_items_actions = [
    "dynamodb:Scan",
    "dynamodb:Query"
  ]
  policy_get_user         = "${local.prefix}-get-user"
  policy_get_user_actions = [
    "dynamodb:GetItem"
  ]
  policy_delete_user         = "${local.prefix}-delete-user"
  policy_delete_user_actions = [
    "dynamodb:DeleteItem"
  ]
  policy_update_user         = "${local.prefix}-update-user"
  policy_update_user_actions = [
    "dynamodb:UpdateItem",
    "dynamodb:PutItem"
  ]

  lambdas = {
    "add_user" : {
      name           = local.lambda_function_name_add_user
      role_name      = local.role_name_add_user
      policy_name    = local.policy_update_item
      policy_actions = local.policy_update_item_actions
      file_name      = "${local.prefix}-add-user.mjs"
      table_name     = local.dynamodb_table_name_user
      env_variables  = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "list_users" : {
      name           = local.lambda_function_name_list_users
      role_name      = local.role_name_list_users
      policy_name    = local.policy_list_items
      policy_actions = local.policy_list_items_actions
      file_name      = "${local.prefix}-list-users.mjs"
      table_name     = local.dynamodb_table_name_user
      env_variables  = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "get_user" : {
      name           = local.lambda_function_name_get_user
      role_name      = local.role_name_get_user
      policy_name    = local.policy_get_user
      policy_actions = local.policy_get_user_actions
      file_name      = "${local.prefix}-get-user.mjs"
      table_name     = local.dynamodb_table_name_user
      env_variables  = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "delete_user" : {
      name           = local.lambda_function_name_delete_user
      role_name      = local.role_name_delete_user
      policy_name    = local.policy_delete_user
      policy_actions = local.policy_delete_user_actions
      file_name      = "${local.prefix}-delete-user.mjs"
      table_name     = local.dynamodb_table_name_user
      env_variables  = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "update_user" : {
      name           = local.lambda_function_name_update_user
      role_name      = local.role_name_update_user
      policy_name    = local.policy_update_user
      policy_actions = local.policy_update_user_actions
      file_name      = "${local.prefix}-update-user.mjs"
      table_name     = local.dynamodb_table_name_user
      env_variables  = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    }
  }

  user_pool_name        = "${local.prefix}-user-pool"
  user_pool_client_name = "${local.prefix}-user-pool-client"
  user_pool_domain_name = "financify"
  callback_urls         = [
    "https://localhost:8080"
  ]
  schema_fields = {
    "email" : {
      required = true
      mutable  = true
      type     = "String"
    },
    "family_name" : {
      required = true
      mutable  = true
      type     = "String"
    },
    "given_name" : {
      required = true
      mutable  = true
      type     = "String"
    }
  }
}