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
cur.execute("SELECT person1_index, person2_index, max_certainty, last_edit, types_list, start_year, end_year, id FROM relationships WHERE is_approved = true;")
edge_tuples = cur.fetchall()

cur.execute("SELECT person_id, group_id FROM group_assignments WHERE is_approved=true;")
group_tuples = cur.fetchall()
groups_by_person = {}
for g in group_tuples:
    if g[0] not in groups_by_person:
        groups_by_person[g[0]] = [g[1]]
    else:
        groups_by_person[g[0]].append(g[1])

print('Total number of nodes:', len(node_tuples))


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

# Get a list of only the node ids
node_ids = list(name_dict.keys())

edges = []
altered = {}
for e in edge_tuples:
    edges.append((e[0], e[1], e[2]))
    print(e[3])
    if e[3] == None or e[3] == '--- []\n':
        altered[(e[0], e[1])] = False
        print('none!')
    elif e[3].split()[2] == '2':# and e[4] != '--- []\n':
        altered[(e[0], e[1])] = False
        print('not altered!')
    else:
        altered[(e[0], e[1])] = True

edge_start = {(e[0], e[1]):e[5] for e in edge_tuples}
edge_end = {(e[0], e[1]):e[6] for e in edge_tuples}
edge_id = {(e[0], e[1]):e[7] for e in edge_tuples}

print('Total number of edges:', len(edges))

# Build full network using NetworkX
G = nx.Graph()
G.add_nodes_from(node_ids)
G.add_weighted_edges_from(edges)

# Calculate three centrality measures
degree = cn.degree_centrality(G)
#betweenness = cn.betweenness_centrality(G, weight='weight')
#eigenvector = cn.eigenvector_centrality(G, weight='weight')

# Add display_name and centrality as node attributes
nx.set_node_attributes(G, 'name', name_dict)
nx.set_node_attributes(G, 'degree',  G.degree(G.nodes()))
nx.set_node_attributes(G, 'historical_significance', sig_dict)
nx.set_node_attributes(G, 'birth_year', birth_dict)
nx.set_node_attributes(G, 'death_year', death_dict)
nx.set_node_attributes(G, 'groups', group_dict)

nx.set_edge_attributes(G, 'altered', altered)
nx.set_edge_attributes(G, 'edge_id', edge_id)
nx.set_edge_attributes(G, 'start_year', edge_start)
nx.set_edge_attributes(G, 'end_year', edge_end)

# Create subgraph based on milton and shakespeare:

    # 1. Get ids for shakespeare and milton
# shakespeare_id = [n[0] for n in node_tuples if n[1] == "Joseph Glanvill"]
# milton_ids = [n[0] for n in node_tuples if n[1] == "Margaret Cavendish"] #There are 3 Margaret miltones in the database, I know I need the second one (index #1)
# shakespeare = shakespeare_id[0]
# milton = milton_ids[1]

# TESTING IDS: Now using Shakespeare and Milton instead of Glanvill and Cavendish
shakespeare = 10010937
milton = 10008309

shakespeare_neighbors = G.neighbors(shakespeare)
milton_neighbors = G.neighbors(milton)
one_degree = shakespeare_neighbors + milton_neighbors + [shakespeare, milton]
print(one_degree)


SG = G.subgraph(one_degree)

# distance_dict = {}
# for n in SG.nodes():
#     if n == shakespeare:
#         distance_dict[n] = 0
#     if n in shakespeare_neighbors and nx.shortest_path_length(SG,n,milton) > 2:
#         distance_dict[n] = 1
#     if n in shakespeare_neighbors and nx.shortest_path_length(SG,n,milton) == 2:
#         distance_dict[n] = 2
#     if n in shakespeare_neighbors and n in milton_neighbors:
#         distance_dict[n] = 3
#     if n in milton_neighbors and nx.shortest_path_length(SG,n,shakespeare) == 2:
#         distance_dict[n] = 4
#     if n in milton_neighbors and nx.shortest_path_length(SG,n,shakespeare) > 2:
#         distance_dict[n] = 5
#     if n == milton:
#         distance_dict[n] = 6

# nx.set_node_attributes(SG, 'distance', distance_dict)
# Create a dictionary for the JSON needed by D3.
new_data = dict(
        data=dict(
            type='network',
            id=str(shakespeare)+","+str(milton),
            attributes=dict(
                primary_people = [str(shakespeare), str(milton)],
                connections=[dict(
                    id = e[2]['edge_id'],
                    type="relationship",
                    attributes=dict(
                        source=e[0],
                        target=e[1],
                        weight=e[2]['weight'],
                        altered=e[2]['altered'],
                        start_year=e[2]['start_year'],
                        end_year=e[2]['end_year']
                    )
                ) for e in SG.edges(data=True)])),
        meta=dict(
            principal_investigators=['Daniel Shore', 'Chris Warren', 'Jessica Otis']),
        included=[dict(
            id=n,
            type="person",
            attributes = dict(
                name=SG.node[n]['name'],
                degree=SG.node[n]['degree'],
                historical_significance=SG.node[n]['historical_significance'],
                birth_year=SG.node[n]['birth_year'],
                death_year=SG.node[n]['death_year'],
                groups=SG.node[n]['groups']
            )) for n in SG.nodes()]
        )

# Output json of the graph.
with open('sharednetwork.json', 'w') as output:
        json.dump(new_data, output, sort_keys=True, indent=4, separators=(',',':'))
