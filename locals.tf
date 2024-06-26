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

  lambda_function_name_trigger_dynamodb_modidy_cognito = "${local.prefix}-trigger-dynamodb-modify-cognito"
  role_name_trigger_dynamodb_modidy_cognito            = "${local.prefix}-trigger-dynamodb-modify-cognito"
  policy_name_trigger_dynamodb_modidy_cognito          = "${local.prefix}-trigger-dynamodb-modify-cognito"

  lambda_function_name_add_user_from_cognito = "${local.prefix}-add-user-from-cognito"
  lambda_function_name_add_user              = "${local.prefix}-add-user"
  lambda_function_name_list_users            = "${local.prefix}-list-users"
  lambda_function_name_get_user              = "${local.prefix}-get-user"
  lambda_function_name_delete_user           = "${local.prefix}-delete-user"
  lambda_function_name_update_user           = "${local.prefix}-update-user"
  lambda_function_name_add_expense_category  = "${local.prefix}-add-expense-category"

  role_name_add_user_from_cognito = "${local.prefix}-add-user-from-cognito"
  role_name_add_user              = "${local.prefix}-add-user"
  role_name_list_users            = "${local.prefix}-list-users"
  role_name_get_user              = "${local.prefix}-get-user"
  role_name_delete_user           = "${local.prefix}-delete-user"
  role_name_update_user           = "${local.prefix}-update-user"
  role_name_add_expense_category  = "${local.prefix}-add-expense-category"

  policy_update_item_from_cognito = "${local.prefix}-update-item-from-cognito"
  policy_update_item              = "${local.prefix}-update-item"
  policy_list_items               = "${local.prefix}-list-items"
  policy_get_user                 = "${local.prefix}-get-user"
  policy_delete_user              = "${local.prefix}-delete-user"
  policy_update_user              = "${local.prefix}-update-user"
  policy_add_expense_category     = "${local.prefix}-add-expense-category"

  lambda_trigger_dynamodb_modify_cognito = {
    name             = local.lambda_function_name_trigger_dynamodb_modidy_cognito
    role_name        = local.role_name_trigger_dynamodb_modidy_cognito
    policy_name      = local.policy_name_trigger_dynamodb_modidy_cognito
    file_name        = "${local.prefix}-trigger-dynamodb-modify-cognito.mjs"
    table_name       = local.dynamodb_table_name_user
    policy_statement = [
      {
        actions = [
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords"
        ]
        resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_stream_arn]
      },
      {
        actions = [
          "dynamodb:ListStreams"
        ]
        resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_stream_arn]
      },
      {
        actions = [
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminGetUser"
        ]
        resources = [module.financify_cognito.arn]
      }
    ]
    env_variables = {
      REGION       = var.region,
      USER_POOL_ID = module.financify_cognito.user_pool_id
    }
  }

  lambdas = {
    "add_user_from_cognito" : {
      name             = local.lambda_function_name_add_user_from_cognito
      role_name        = local.role_name_add_user_from_cognito
      policy_name      = local.policy_update_item_from_cognito
      file_name        = "${local.prefix}-add-user-from-cognito.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:UpdateItem",
            "dynamodb:PutItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "add_user" : {
      name             = local.lambda_function_name_add_user
      role_name        = local.role_name_add_user
      policy_name      = local.policy_update_item
      file_name        = "${local.prefix}-add-user.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:UpdateItem",
            "dynamodb:PutItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "list_users" : {
      name             = local.lambda_function_name_list_users
      role_name        = local.role_name_list_users
      policy_name      = local.policy_list_items
      file_name        = "${local.prefix}-list-users.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:Scan",
            "dynamodb:Query"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "get_user" : {
      name             = local.lambda_function_name_get_user
      role_name        = local.role_name_get_user
      policy_name      = local.policy_get_user
      file_name        = "${local.prefix}-get-user.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:GetItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "delete_user" : {
      name             = local.lambda_function_name_delete_user
      role_name        = local.role_name_delete_user
      policy_name      = local.policy_delete_user
      file_name        = "${local.prefix}-delete-user.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:DeleteItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "update_user" : {
      name             = local.lambda_function_name_update_user
      role_name        = local.role_name_update_user
      policy_name      = local.policy_update_user
      file_name        = "${local.prefix}-update-user.mjs"
      table_name       = local.dynamodb_table_name_user
      policy_statement = [
        {
          actions = [
            "dynamodb:UpdateItem",
            "dynamodb:PutItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_user
      }
    },
    "add_expense_category" : {
      name             = local.lambda_function_name_add_expense_category
      role_name        = local.role_name_add_expense_category
      policy_name      = local.policy_add_expense_category
      file_name        = "${local.prefix}-add-expense-category.mjs"
      table_name       = local.dynamodb_table_name_expense_categories
      policy_statement = [
        {
          actions = [
            "dynamodb:UpdateItem",
            "dynamodb:PutItem"
          ]
          resources = [module.financify_dynamodb[local.dynamodb_table_name_expense_categories].dynamodb_arn]
        }
      ]
      env_variables = {
        TABLE_NAME = local.dynamodb_table_name_expense_categories
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