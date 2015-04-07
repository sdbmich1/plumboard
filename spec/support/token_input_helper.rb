module TokenInputHelper
  def self.fill_token_input(page, locator, options)
    raise "Must pass a hash containing 'with'" unless options.is_a?(Hash) && options.has_key?(:with)
    page.execute_script %Q{$('#{locator}').val('#{options[:with]}').keydown()}
    sleep(5)
    find(:xpath, "//div[@class='token-width']/ul/li[contains(string(),'#{options[:with]}')]").click
  end
end
