class Step < ActiveRecord::Base
    has_one :nextStep, :foreign_key => 'next_step_id', class_name: "Step"
end
