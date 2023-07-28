
# Validation of GCSPET solutions
# requires: instance, solution
# evaluates:
# - job precence
# - job execution validity (c_j - p_j ≥ a_j)
# - job precedence order
# - 

struct Validator
    instance::Instance
    solution::Solution
    
end