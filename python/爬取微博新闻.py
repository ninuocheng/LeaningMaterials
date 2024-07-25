from selenium import webdriver
driver = webdriver.Chrome()
driver.get('https://kmy.jsyks.com/hn')
lis = driver.find_elements('.Content li')
for li in lis:
    answer = li.get_attribute('c')
    print(answer)