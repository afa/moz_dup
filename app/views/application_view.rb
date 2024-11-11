class ApplicationView < Dry::View
  config.paths = File.join(__dir__, '../templates')
  config.part_namespace = Parts
  config.layout = 'application'

  expose :current_account, layout: true

  private

  def current_account(account:)
    account&.user
  end
end
