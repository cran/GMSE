library("testthat");
library("GMSE");
context("User model");

test_that("Dimensions of observation arrays in user model are correct", {
    skip_on_cran();
    res <- make_resource(model              = "IBM", 
                         resource_quantity  = 100, 
                         resource_types     = 2, 
                         rows               = 10, 
                         cols               = 10, 
                         move               = 1, 
                         rm_pr              = 0,
                         lambda             = 0,
                         consumption_rate   = c(0.1, 0.2),
                         max_age            = 5
    );
    
    land  <-  make_landscape(model        = "IBM", 
                             rows         = 10, 
                             cols         = 10, 
                             cell_types   = 1, 
                             cell_val_mn  = 1, 
                             cell_val_sd  = 0, 
                             cell_val_max = 1, 
                             cell_val_min = 1,
                             layers       = 3, 
                             ownership    = 1,
                             owners       = 1,
                             public_land  = 0
    );
    
    paras <- c(0, 1, 1, 2, 2, 100, 100, 0, 0, 1, 10, 20, 10, 10, 1, 1, 1, 1, 12,
               1, 0, 100, 10, 20, 20, 2, 0.1, 0.1, 0, 5, 7, 11, 100, 4, 5, 6, 3,
               9, 10, 18, 19, 20, 17, 8, 1, 1, 15, 14, 1, 4, 5, 6, 10, 12, 2, 
               17, 1, 2, 3, 13, 3, -1, -1, 1, 0, 2, 2, 8, 7, 13, 4, 7, 0, 17, 
               17, 18, 19, 20, 21, 0.5, 1, 2, 15, 0, 0, 0, 0, 0, 1, 1, 1, 1, 
               1, 1, 1, 1, 10, 1000, 100, 100, 0, 0, 10, 0, 0, 0, 1, 0, 0, 0, 0,
               1, 16, 1000, 10, 20, 0, 0, 21, 0, 13, 1, 22, 23, 1, 0, 0, 
               24, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10);
    
    agents  <-  make_agents(model        = "IBM",
                            agent_number = 2,
                            type_counts  = c(1,1),
                            move         = 0,
                            vision       = 20,
                            rows         = 100,
                            cols         = 100
    )
    
    
    interaction_tabl <- make_interaction_table(res, land);
    int_array        <- make_interaction_array(res, land);
    
    obs   <- observation(RESOURCES      = res,
                         LAND           = land,
                         PARAS          = paras,
                         AGENTS         = agents,
                         inter_tabl     = interaction_tabl,
                         fixed_mark     = paras[11],
                         times_observe  = paras[12],
                         res_min_age    = paras[17],
                         agent_type     = 0,
                         type_cat       = 1,
                         observe_type   = paras[9],
                         res_move_obs   = paras[20]
    );
    
    res_opts  <- c(1, 1, 1, 1, 1);
    lnd_opts  <- c(1, 1);
    min_cost  <- 10;
    cost      <- make_costs(agents, res, res_opts, lnd_opts, min_cost);
    action    <- make_utilities(agents, res);
    
    usem <- user(RESOURCES   = res,
                 AGENTS      = agents,
                 LAND        = land, 
                 PARAS       = paras,
                 COST        = cost,
                 ACTION      = action,
                 INTERACT    = int_array,
                 inter_tabl  = interaction_tabl,
                 model       = "IBM"
    );
    
    expect_equal(length(usem), 6);
    expect_equal(dim(usem[[1]]), c(100, 22));
    expect_equal(dim(usem[[2]]), c(2, 27));
    expect_equal(dim(usem[[3]]), c(10, 10, 3));
    expect_equal(dim(usem[[4]]), c(7, 13, 2));
    expect_equal(dim(usem[[5]]), c(7, 13, 2));
})

test_that("Users act according to costs", {
    skip_on_cran();
    res <- make_resource(model              = "IBM", 
                         resource_quantity  = 100, 
                         resource_types     = 2, 
                         rows               = 10, 
                         cols               = 10, 
                         move               = 1, 
                         rm_pr              = 0,
                         lambda             = 0,
                         consumption_rate   = c(0.1, 0.2),
                         max_age            = 5
    );
    
    land  <-  make_landscape(model        = "IBM", 
                             rows         = 10, 
                             cols         = 10, 
                             cell_types   = 1, 
                             cell_val_mn  = 1, 
                             cell_val_sd  = 0, 
                             cell_val_max = 1, 
                             cell_val_min = 1,
                             layers       = 3, 
                             ownership    = 1,
                             owners       = 1,
                             public_land  = 0
    );
    
    paras <- c(0, 1, 1, 2, 2, 100, 100, 0, 0, 1, 10, 20, 10, 10, 1, 1, 1, 1, 12,
               1, 0, 100, 10, 20, 20, 2, 0.1, 0.1, 0, 5, 7, 11, 100, 4, 5, 6, 3,
               9, 10, 18, 19, 20, 17, 8, 1, 1, 15, 14, 1, 4, 5, 6, 10, 12, 2, 
               17, 1, 2, 3, 13, 3, -1, -1, 1, 0, 2, 2, 8, 7, 13, 4, 7, 0, 17, 
               17, 18, 19, 20, 21, 0.5, 1, 2, 15, 0, 0, 0, 0, 0, 1, 1, 1, 1, 
               1, 1, 1, 1, 10, 1000, 100, 100, 0, 0, 10, 0, 0, 0, 1, 0, 0, 0, 0,
               1, 16, 1000, 10, 20, 0, 0, 21, 0, 13, 1, 22, 23, 1, 0, 0, 
               24, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10);
    
    agents  <-  make_agents(model        = "IBM",
                            agent_number = 2,
                            type_counts  = c(1,1),
                            move         = 0,
                            vision       = 20,
                            rows         = 100,
                            cols         = 100
    )
    
    
    interaction_tabl <- make_interaction_table(res, land);
    int_array        <- make_interaction_array(res, land);
    
    obs   <- observation(RESOURCES      = res,
                         LAND           = land,
                         PARAS          = paras,
                         AGENTS         = agents,
                         inter_tabl     = interaction_tabl,
                         fixed_mark     = paras[11],
                         times_observe  = paras[12],
                         res_min_age    = paras[17],
                         agent_type     = 0,
                         type_cat       = 1,
                         observe_type   = paras[9],
                         res_move_obs   = paras[20]
    );
    
    res_opts  <- c(1, 1, 1, 1, 1);
    lnd_opts  <- c(1, 1);
    min_cost  <- 10;
    cost      <- make_costs(agents, res, res_opts, lnd_opts, min_cost);
    action    <- make_utilities(agents, res);
    
    usem <- user(RESOURCES   = res,
                 AGENTS      = agents,
                 LAND        = land, 
                 PARAS       = paras,
                 COST        = cost,
                 ACTION      = action,
                 INTERACT    = int_array,
                 inter_tabl  = interaction_tabl,
                 model       = "IBM"
    );
    
    expect_equal(min(usem[[5]][,1:7,1]), 100001);
    expect_equal(max(usem[[5]][,1:7,2]), 100001);
    expect_equal(min(usem[[5]]), 10);
    expect_equal(max(usem[[5]]), 100001);
})

test_that("Managers don't act like users", {
    skip_on_cran();
    res <- make_resource(model              = "IBM", 
                         resource_quantity  = 100, 
                         resource_types     = 2, 
                         rows               = 10, 
                         cols               = 10, 
                         move               = 1, 
                         rm_pr              = 0,
                         lambda             = 0,
                         consumption_rate   = c(0.1, 0.2),
                         max_age            = 5
    );
    
    land  <-  make_landscape(model        = "IBM", 
                             rows         = 10, 
                             cols         = 10, 
                             cell_types   = 1, 
                             cell_val_mn  = 1, 
                             cell_val_sd  = 0, 
                             cell_val_max = 1, 
                             cell_val_min = 1,
                             layers       = 3, 
                             ownership    = 1,
                             owners       = 1,
                             public_land  = 0
    );
    
    paras <- c(0, 1, 1, 2, 2, 100, 100, 0, 0, 1, 10, 20, 10, 10, 1, 1, 1, 1, 12,
               1, 0, 100, 10, 20, 20, 2, 0.1, 0.1, 0, 5, 7, 11, 100, 4, 5, 6, 3,
               9, 10, 18, 19, 20, 17, 8, 1, 1, 15, 14, 1, 4, 5, 6, 10, 12, 2, 
               17, 1, 2, 3, 13, 3, -1, -1, 1, 0, 2, 2, 8, 7, 13, 4, 7, 0, 17, 
               17, 18, 19, 20, 21, 0.5, 1, 2, 15, 0, 0, 0, 0, 0, 1, 1, 1, 1, 
               1, 1, 1, 1, 10, 1000, 100, 100, 0, 0, 10, 0, 0, 0, 1, 0, 0, 0, 0,
               1, 16, 1000, 10, 20, 0, 0, 21, 0, 13, 1, 22, 23, 1, 0, 0, 
               24, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10);
    
    agents  <-  make_agents(model        = "IBM",
                            agent_number = 2,
                            type_counts  = c(1,1),
                            move         = 0,
                            vision       = 20,
                            rows         = 100,
                            cols         = 100
    )
    
    
    interaction_tabl <- make_interaction_table(res, land);
    int_array        <- make_interaction_array(res, land);
    
    obs   <- observation(RESOURCES      = res,
                         LAND           = land,
                         PARAS          = paras,
                         AGENTS         = agents,
                         inter_tabl     = interaction_tabl,
                         fixed_mark     = paras[11],
                         times_observe  = paras[12],
                         res_min_age    = paras[17],
                         agent_type     = 0,
                         type_cat       = 1,
                         observe_type   = paras[9],
                         res_move_obs   = paras[20]
    );
    
    res_opts  <- c(1, 1, 1, 1, 1);
    lnd_opts  <- c(1, 1);
    min_cost  <- 10;
    cost      <- make_costs(agents, res, res_opts, lnd_opts, min_cost);
    action    <- make_utilities(agents, res);
    
    usem <- user(RESOURCES   = res,
                 AGENTS      = agents,
                 LAND        = land, 
                 PARAS       = paras,
                 COST        = cost,
                 ACTION      = action,
                 INTERACT    = int_array,
                 inter_tabl  = interaction_tabl,
                 model       = "IBM"
    );
    
    expect_equal(max(usem[[4]][,3:13,1]), 0);
})


test_that("Users can get a budget increment from their yield", {
    skip_on_cran();
    sim <- gmse(time_max = 2, usr_yld_budget = 1, land_ownership = TRUE, 
                stakeholders = 1, plotting = FALSE);
    yield_incr <- sim[["agents"]][[2]][2, 26];
    
    expect_equal(yield_incr > 0, TRUE);
})



