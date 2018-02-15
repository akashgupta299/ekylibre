class ActivityDecorator < Draper::Decorator
  delegate_all

  def production_costs
    calcul_productions_costs
  end

  def global_costs
    calcul_global_costs
  end

  def human_global_costs
    human_costs(global_costs)
  end

  def sum_interventions_working_zone_area
    InterventionTarget
      .of_interventions(object.interventions)
      .map(&:working_zone_area)
      .sum
      .in(:hectare)
      .round(2)
      .to_d
  end

  def working_zone_area
    activity_productions = decorated_activity_productions
    working_zone = 0.in(:hectare)

    activity_productions.each do |activity_production|
      working_zone += activity_production.working_zone_area
    end

    working_zone
      .in(:hectare)
      .round(3)
      .l
  end

  private


  def sum_costs(activity_costs, costs)
    activity_costs.each { |key, value| activity_costs[key] = activity_costs[key] + costs[key] }
  end

  def multiply_costs(costs, multiplier)
    costs.each { |key, value| costs[key] = value * multiplier }
  end

  def divider_costs(costs, divider)
    costs.each { |key, value| costs[key] = value / divider }
  end

  def human_costs(costs)
    costs.each { |key, value| costs[key] = costs[key].to_f.round(2) }
  end

  def decorated_activity_productions
    activity_productions = object
                            .productions
                            .of_current_campaigns

    ActivityProductionDecorator.decorate_collection(object.productions)
  end

  def calcul_global_costs
    costs = { total: 0, inputs: 0, doers: 0, tools: 0, receptions: 0 }
    activity_productions = decorated_activity_productions

    activity_productions.each do |activity_production|
      activity_production_costs = activity_production.global_costs

      sum_costs(costs, activity_production_costs)
    end

    costs
  end

  def calcul_productions_costs
    costs = new_productions_costs_hash
    activity_productions = decorated_activity_productions
    sum_surface_area = 0.in(:hectare)
    sum_parameters_cultivated_hectare = { total: 0, inputs: 0, doers: 0, tools: 0, receptions: 0 }

    activity_productions.each do |activity_production|
      activity_production_costs = activity_production.global_costs

      sum_costs(costs[:global_costs], activity_production_costs)
      human_costs(costs[:global_costs])

      sum_surface_area += activity_production.net_surface_area
      multiply_costs(activity_production_costs, calculated_surface_area(activity_production.net_surface_area))
      sum_costs(costs[:cultivated_hectare_costs], activity_production_costs)
    end


    divider_costs(costs[:cultivated_hectare_costs], calculated_surface_area(sum_surface_area))
    human_costs(costs[:cultivated_hectare_costs])

    sum_costs(costs[:working_hectare_costs], costs[:global_costs])
    divider_costs(costs[:working_hectare_costs], sum_interventions_working_zone_area)
    human_costs(costs[:working_hectare_costs])

    costs
  end

  def sum_activities_productions_surface_area
    object
      .productions
      .map(&:net_surface_area)
      .sum
  end

  def new_productions_costs_hash
    {
      global_costs: {
        total: 0,
        inputs: 0,
        doers: 0,
        tools: 0,
        receptions: 0
      },
      cultivated_hectare_costs: {
        total: 0,
        inputs: 0,
        doers: 0,
        tools: 0,
        receptions: 0
      },
      working_hectare_costs: {
        total: 0,
        inputs: 0,
        doers: 0,
        tools: 0,
        receptions: 0
      }
    }
  end

  def calculated_surface_area(surface_area)
    surface_area
      .in(:hectare)
      .round(2)
      .to_d
  end
end