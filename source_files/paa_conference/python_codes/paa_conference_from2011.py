from lxml import html
import requests
import os
import codecs

link_part1 = "http://paa"
link_part2 = ".princeton.edu/sessions/"
os.chdir('/home/valeire/git_repos/gendered_authorship')
    
f = codecs.open('paa_conference_from2011.txt', 'w', 'utf-8')

titles = 'year\tsession_number\tsession_title\ttitle\tabstract'

for i in range(1,8):
    titles = titles + '\tauthor'+str(i)+'_firstname\tauthor'+str(i)+'_name'

f.write(titles)

for i in range(2011, 2015):
    conference = link_part1 + str(i) + '.princeton.edu/days'
    page = requests.get(conference)
    tree = html.fromstring(page.text)
    rts = tree.xpath('//td[@class="rt"]')
    length = len(rts)
    for j in rts:
        if 'P' in j.text:
            length = length - 1
    for j in range(1,length+1):
        link = link_part1 + str(i) + link_part2 + str(j)
        page = requests.get(link)
        tree = html.fromstring(page.text)
        session_title = tree.xpath('//h2')[0].itertext()
        for z in session_title:
            s_title = z
        papers = tree.xpath('//li/p')
        for k in papers:
            paper_titles = k.xpath('a')
            paper_authors = k.xpath('span')
            if len(paper_titles) > 0:                
                abstract_link = link_part1 + str(i) + ".princeton.edu" + paper_titles[0].attrib['href']
                abstract_page = requests.get(abstract_link)
                abstract_tree = html.fromstring(abstract_page.text)
                abstract_divs = abstract_tree.xpath('//div[@class="abstract"]')
                abstract = ""
                if len(abstract_divs) > 0:
                    abstract = abstract_divs[0].text.replace('"','')
                    abstract = abstract.replace('\r',' ')
                    abstract = abstract.replace('\n',' ')
                title = paper_titles[0].text.replace('"','')
                f.write('\n'+str(i)+'\t'+str(j)+'\t'+s_title+'\t'+title+'\t'+abstract)
                for l in paper_authors:
                    author = l.text.split(' ',1)
                    author_1 = author[0]
                    author_2 = author[1]
                    f.write('\t'+author_1+'\t'+author_2)
          

f.close()
        

                        
