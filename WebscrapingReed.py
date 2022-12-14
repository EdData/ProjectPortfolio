from bs4 import BeautifulSoup
import requests
import pandas as pd


headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36' 
           '(KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'}

postList = []
def getPosts(page):
    url = 'https://www.reed.co.uk/jobs/data-jobs-in-london?pageno={}'   
    r = requests.get(url, headers=headers)
    soup = BeautifulSoup(r.text, 'html.parser')
        
    posts = soup.find_all('article', {'class': 'job-result-card'})
    print(posts)
        
    for item in posts:
        post = {
        'title': item.find('header', {'class': 'job-result-heading'}).text,
        'locationSalary': item.find('ul', {'class': 'job-metadata'}).text,
        'description': item.find('div', {'class': 'job-result-description'}).text,
        }
        postList.append(post)
    return
    
for x in range(1, 400):
    getPosts(x)

df = pd.DataFrame(postList)
df.to_csv('ReedJobs.csv', index=False, encoding='utf-8')
