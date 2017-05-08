#! /usr/bin/env python3

import psycopg2
import networkx as nx
import json
from networkx.algorithms import centrality as cn
from networkx.algorithms import connectivity as ct

# Connect to database and open cursor
conn = psycopg2.connect('dbname=mysdfb')
cur = conn.cursor()

# Get nodes as list of tuples from database
cur.execute("SELECT id, display_name, historical_significance, ext_birth_year, ext_death_year FROM people WHERE is_approved = true;")
node_tuples = cur.fetchall()

# Get edges as list of tuples from database
cur.execute("SELECT person1_index, person2_index, max_certainty, last_edit, types_list, start_year, end_year, id FROM relationships WHERE is_approved = true and max_certainty >=60;")
edge_tuples = cur.fetchall()

cur.execute("SELECT people.id, group_assignments.start_year, group_assignments.end_year, people.birth_year_type, people.death_year_type FROM people INNER JOIN group_assignments ON people.id = group_assignments.person_id WHERE people.is_approved = true AND group_id = 81 AND group_assignments.is_approved = true;")
group_tuples = cur.fetchall()
print(group_tuples)

cur.execute("SELECT person_id, group_id FROM group_assignments WHERE is_approved=true;")
all_group_tuples = cur.fetchall()
groups_by_person = {}
for g in all_group_tuples:
    if g[0] not in groups_by_person:
        groups_by_person[g[0]] = [g[1]]
    else:
        groups_by_person[g[0]].append(g[1])

#print('Total number of nodes:', len(node_tuples))


# Make node list into a dictionary (for NetworkX attribute input)
name_dict = {}
sig_dict = {}
birth_dict = {}
death_dict = {}
group_dict = {}
for n in node_tuples:
    name_dict[n[0]] = n[1]
    sig_dict[n[0]] = n[2]
    birth_dict[n[0]] = n[3]
    death_dict[n[0]] = n[4]
    try:
        group_dict[n[0]] = groups_by_person[n[0]]
    except KeyError:
        group_dict[n[0]] = None

start_year_dict = {}
end_year_dict = {}
byear_type_dict = {}
dyear_type_dict = {}
for g in group_tuples:
    start_year_dict[g[0]] = g[1]
    end_year_dict[g[0]] = g[2]
    byear_type_dict[g[0]] = g[3]
    dyear_type_dict[g[0]] = g[4]

# Get a list of only the node ids
node_ids = list(name_dict.keys())

edges = []
altered = {}
for e in edge_tuples:
    edges.append((e[0], e[1], e[2]))
    if e[3] == None or e[3] == '--- []\n':
        altered[(e[0], e[1])] = False
    elif e[3].split()[2] == '2':# and e[4] != '--- []\n':
        altered[(e[0], e[1])] = False
    else:
        altered[(e[0], e[1])] = True

#print('Number of edges with confidence 60% and above:', len(edges))

edge_start = {(e[0], e[1]):e[5] for e in edge_tuples}
edge_end = {(e[0], e[1]):e[6] for e in edge_tuples}
edge_id = {(e[0], e[1]):e[7] for e in edge_tuples}

# Build full network using NetworkX
G = nx.Graph()
G.add_nodes_from(node_ids)
G.add_weighted_edges_from(edges)

# Calculate three centrality measures
# degree = cn.degree_centrality(G)
#betweenness = cn.betweenness_centrality(G, weight='weight')
#eigenvector = cn.eigenvector_centrality(G, weight='weight')

# Add display_name and centrality as node attributes
nx.set_node_attributes(G, 'name', name_dict)
nx.set_node_attributes(G, 'degree', G.degree(G.nodes()))#degree)
nx.set_node_attributes(G, 'historical_significance', sig_dict)
nx.set_node_attributes(G, 'birth_year', birth_dict)
nx.set_node_attributes(G, 'death_year', death_dict)
nx.set_node_attributes(G, 'groups', group_dict)

nx.set_edge_attributes(G, 'altered', altered)
nx.set_edge_attributes(G, 'edge_id', edge_id)
nx.set_edge_attributes(G, 'start_year', edge_start)
nx.set_edge_attributes(G, 'end_year', edge_end)

# Create subgraph based on Virginia Company
vc_ids = [k for k,v in group_dict.items() if type(v) == int and 81 in v]

all_distance = list(set(sum([G.neighbors(k) for k in vc_ids], [])))
#print(all_distance+vc_ids)
all_vc_nodes = all_distance+vc_ids
# distance_dict = {}
# for a in all_vc_nodes:
#     if a in vc_ids:
#         distance_dict[a] = 0
#     else:
#         distance_dict[a] = 1


SG = G.subgraph(all_vc_nodes)

# nx.set_node_attributes(SG, 'distance', distance_dict)


# Create a dictionary for the JSON needed by D3.
new_data = dict(
        data=dict(
            type='networks',
            id='1',
            attributes=dict(
                nodes=[dict(
                    id=n,
                    person_info=dict(name=SG.node[n]['name']),
                    degree=SG.node[n]['degree']) for n in SG.nodes()],
                links=[dict(
                    source=e[0],
                    target=e[1],
                    weight=e[2]['weight'],
                    altered=e[2]['altered'],
                    start_year=e[2]['start_year'],
                    end_year=e[2]['end_year'],
                    id=e[2]['edge_id']) for e in SG.edges(data=True)])),
        errors=[dict(
            status='404',
            title='Page not found')],
        meta=dict(
            principal_investigators=['Daniel Shore', 'Chris Warren', 'Jessica Otis']),
        included=[dict(
            type='people',
            id=n,
            name=SG.node[n]['name'],
            historical_significance=SG.node[n]['historical_significance'],
            birth_year=SG.node[n]['birth_year'],
            birth_year_type=byear_type_dict[n],
            death_year=SG.node[n]['death_year'],
            death_year_type=dyear_type_dict[n],
            start_year=start_year_dict[n],
            end_year=end_year_dict[n]) for n in vc_ids]
        )

# Output json of the graph.
with open('groupnetwork.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
