
def sprite_id(id):
    fileno = id // (512 * 512)
    base = fileno * 512 * 512
    page_size = 512
    if id < 512 * 512 * 2 and id >= 110000:
        fileno = 1
        base = 110000
        page_size = 1000
    sheetno, tileidx = divmod(id - fileno * 512 * 512, page_size)
    return (fileno, sheetno, tileidx)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Resolve a sprite ID to its tile sheet and index')
    parser.add_argument('id', type=int, help='The sprite ID to resolve')
    args = parser.parse_args()
    fileno, sheetno, tileidx = sprite_id(args.id)
    print(f"File number: {fileno}, Sheet number: {sheetno}, Tile index: {tileidx}")
